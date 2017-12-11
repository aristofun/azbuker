# coding: utf-8
# Date: 3.07.12
# Time: 16:22


# must catch 404 errors on its own
#noinspection RubyClassVariableUsageInspection,RubyStringKeysInHashInspection
class OzonBookParser
  @@TOPLEVEL = {
      'book' => 3, # fiction
      'nonfiction' => {
          '1137926' => 2, # Компьютерная литература
          '1137955' => 2, # Научная и техническая литература
          '1138260' => 2, # Общественные и гуманитарные науки
          '1137930' => -1, # Публицистика
          '1137929' => -1, # Календари, нетекстовые издания, словари, общие справочники
          :default => 4
      },
      'family' => 5, # kids
      'edlitera' => 1, # study lit
      'business' => 0, # ebiz lit
      'div_rar' => 6, # Антиквар и винтаж
      'aged' => 6 # Книги 30-60-х годов XX века
  }


  attr_accessor :bookid, :authors_all, :author_last, :title, :coverid, :genre

  def initialize(bookid, page, agent)
    @bookid = bookid
    @page = page
    @to_skip = false
    @agent = agent
  end

  # returns true if ok, false if book is not russian either english
  def parse_book!
    # if not book
    unless @page.search("a[@class='eBreadCrumbs_link']/@href").to_a[0].to_s.include?('div_book')
      @to_skip = true
      return false
    end

    @genre = get_genre(
        @page.search("a[@class='eBreadCrumbs_link']/@href").to_a[1].to_s,
        @page.search("a[@class='eBreadCrumbs_link']/@href").to_a[2].to_s
    # @page.search("ul.navLine/li:nth-of-type(2)").search("*/a/@href").text, # li with 1-st level category
    # @page.search("ul.navLine/li:nth-of-type(3)").search("*/a/@href").text # li with 2-nd level category
    )
    @title = @page.search("div.details-main//h1").text.sub(/\(+[^\(\)]*\)+\s*$/, '').squish
    @author_last, @authors_all = get_authors
    # @coverid = /\/(\w+)\.jpg/.match(@page.search("div#detailGalleryMini//div.img/img/@src").text)
    @coverid = /\/(\w+)\.jpg/.match(@page.search("//img[contains(@class, 'eMicroGallery_fullImage')]/@src").text)
    @coverid = @coverid[1] if @coverid.present?
    # cover can be 'noimg_200x200'

    # skip not russian & not english books
    # languages = @page.search("//div[contains(@class,'product-detail')]/p[contains(text(), 'Языки')]").text.squish
    languages = @page.search("//p[@itemprop='inLanguage']").text.squish

    if (languages.present? && languages !~ /(Английский|Русский)/ui) || @coverid =~ /noimg/ ||
        @coverid.blank? || !OzonBookParser.cover_exist(@agent, @coverid)
      @to_skip = true
      return false
    end

    state_valid?
  end

  def state_valid?
    (@genre.present? && @title.present? && @authors_all.present? && @coverid.present?)
  end

  def self.cover_exist(agent, coverid)
    begin
      url = Book.ozon_cover(coverid, :x120)
      pg = agent.head(url)
      return (pg.code == "200")
    rescue Exception => e
      return false
    end
  end


  def should_skip?
    @to_skip
  end

  def to_s
    "#{title[0..50]} | #{authors_all[0..25]} | #{author_last} | #{genre} | cover: #{coverid}"
  end

  private
  def get_genre(toplevel, subgenre)
    return 6 if @page.search("div.bDetailLogoBlock:contains('Антикварное')").text.present? ||
        @page.search("div.bDetailLogoBlock:contains('Издание 30-60-x')").text.present?
    # (@page.search("div.product-detail/p.tov_prop:contains('Антикварное')").text.present? &&
    # @page.search("div.product-detail/p.tov_prop:contains('Издание 30-60-х')").text.present?)

    context = /context\/(\w+)/.match(toplevel)
    if context.blank?
      #@to_skip = true
      return -1
    end
    context = context[1]

    if @@TOPLEVEL[context].is_a? Hash
      catalog = /catalog\/(\w+)/.match(subgenre)
      catalog = catalog[1] if catalog.present?
      return @@TOPLEVEL[context][catalog] || @@TOPLEVEL[context][:default]
    end

    @@TOPLEVEL[context] || -1 # MIsc. books by default
  end

  def get_authors
    main_authors = @page.search("//div[@title='автор' and @class='eShelfTile_ItemPerson']/../span[@class = 'eShelfTile_ItemNameText']")[0..2].map(&:text)

    # @page.search("//div[contains(@class, 'gallery-group')]/div[@class='l']/p[@class
    # = 'tov_prop' and contains(text(), 'автор')]/../p[@class='misc']/a")[0..2].map(&:text)

    # try to get authors from short string:
    if main_authors.blank?
      _main_authors = @page.search("//p[@itemprop='author' and contains(text(), 'Автор')]").text.squish

      # @page.search("//div[contains(@class,'product-detail')]/p[contains(text(), 'Автор')]").text.squish
      main_authors = Author.split_string(_main_authors.split(':')[1]) if _main_authors =~ /:\s+\S+/
    end

    editor = @page.search("//div[@title='редактор' and @class='eShelfTile_ItemPerson']/../span[@class = 'eShelfTile_ItemNameText']")[0]
    # @page.search("//div[contains(@class, 'gallery-group')]/div[@class='l']/p[@class =
    # 'tov_prop' and contains(text(), 'редактор')]/../p[@class='misc']/a")[0]

    last, all = "неизвестен", "неизвестен"

    if main_authors.empty?
      if editor.blank?
        publisher = @page.search("//p[@itemprop='publisher']")[0]
        # @page.search("//div[contains(@class,'product-detail')]/p[contains(text(),'Издательство')]")
        if publisher.present?
          all = publisher.text.squish.split(':')[1].squish
        end
      else
        f, m, last = Author.extract_first_middle_last(editor.text)
        all = editor.text
      end
    else
      f, m, last = Author.extract_first_middle_last(main_authors[0])
      all = main_authors.join(', ')
    end
    return last, all
  end
end