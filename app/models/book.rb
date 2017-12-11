# coding: utf-8
class Book < ActiveRecord::Base
  has_and_belongs_to_many :authors
  has_many :lots, :dependent => :delete_all

  def self.ozon_cover(ozon_id, size = :x300)
    size = "/c#{size[1..-1]}"
    size = '' if (size == '/c300' || size == '/criginal')
    "http://static.ozone.ru/multimedia/books_covers#{size}/#{ozon_id}.jpg"
  end

  attr_accessible :title, :ozon_coverid, :ozonid, :genre

  validates :genre,
            :numericality => {:greater_than_or_equal_to => -1, :less_than_or_equal_to => 7,
                              :only_integer => true}

  validates :title,
            :presence => true,
            :allow_blank => false,
            :length => {:maximum => 255}

  validates :min_price,
            :numericality => true,
            :allow_blank => true

  scope :present, :conditions => ['books.lots_count > 0']
  scope :absent, :conditions => ['books.lots_count = 0']
  scope :unauthored, joins('left outer join authors_books on books.id=authors_books.book_id').
        where('authors_books.author_id is null')

  scope :fresh_first, :order => 'books.updated_at DESC'

  # Complex Books obtainer
  # can be chained to Author.books.custom...
  #
  # Valid options are:
  #   * <tt>:genre</tt> – genre of a books to look lots for
  #   * <tt>:city</tt>
  #   * <tt>:is_active</tt> – default true
  # Order & paging:
  #   * <tt>:order_by</tt> – can be *:date*, *:price* or *:author*, default *:date*
  #   * <tt>:order_to</tt> – *:desc* (default) or *:asc*
  #   * <tt>:limit</tt> - default 12
  #   * <tt>:page</tt> – default 1
  #
  #  *Full text search:*
  #   * <tt>:q</tt> – query string
  def self.custom(options = {})
    #cleanup vars
    options[:city] = nil if options[:city].to_i == -1
    options[:limit] ||= 16
    options[:page] ||= 1
    options[:is_active] = true if options[:is_active].nil?

    options[:order_to] = case options[:order_to].to_s.casecmp('asc')
                           when 0 then
                             'ASC'
                           else
                             'DESC'
                         end

    options[:order_by] = case options[:order_by].to_s
                           when 'price' then
                             'min(lots.price) '
                           when 'author' then
                             'min(authors.last) '
                           else
                             #'min(lots.updated_at) '
                             'books.updated_at'
                         end

    condit1 = ''
    condit1 += 'books.genre = :genre AND ' if options[:genre].present?
    condit1 += 'lots.cityid IN (:cityid, -1) AND ' if options[:city].present?
    condit1 += 'lots.is_active = :lotactive'

    group_str = 'books.id'
    condit2 = ''

    # Fulltext search part
    unless options[:q].blank?
      q = prepare_ts(options[:q].squish)
      titlevec = "to_tsvector('russian', books.title)"
      authvec = "to_tsvector('russian', authors.full)"
      ts_q = "to_tsquery(#{sanitize(q)})"
      rank = "(max(ts_rank(#{titlevec}, #{ts_q})) + max(ts_rank(#{authvec}, #{ts_q}))) DESC,"

      #condit2 += "#{titlevec} @@ #{ts_q} AND #{authvec} @@ #{ts_q}"
      condit2 += "(#{titlevec} || #{authvec}) @@ #{ts_q}" # better performance version
      group_str = 'books.id'
      options[:order_by2] = rank
    end

    joins(:authors).joins(:lots).
        select('books.*, min(lots.price) as min_price, count(DISTINCT lots.id) as lots_count').
        where(condit1, {:lotactive => options[:is_active], :cityid => options[:city], :genre => options[:genre]}).
        where(condit2).
        order("#{options[:order_by2]} #{options[:order_by]} #{options[:order_to]}").
        #having('count(lots.id) > 0')#why wasit?
        group(group_str).
        paginate(:page => options[:page], :per_page => options[:limit].to_i)
  end

  # finds books of all or any of given authors, except one book
  def self.other_books(authors, title = nil, all = true, except_bookid = nil)
    conditstr = 'authors.id IN (:authors)'
    conditstr += ' AND lower(books.title) = lower(:title)' unless title.nil?
    conditstr += ' AND books.id != :except_bookid' unless except_bookid.nil?
    having, having2 = [], []
    having = ['COUNT(DISTINCT authors_books.author_id) = ?', authors.length] if all
    having2 = ['count(authors.id) = ?', authors.length] if all

    candidates = joins(:authors).where(
        [conditstr, {
            :title => title,
            :authors => authors,
            :except_bookid => except_bookid
        }]).select('books.id').group('books.id').having(having).to_sql

    joins(:authors).where("books.id = ANY(ARRAY(#{candidates}))").group('books.id').having(having2)
    .readonly(false)
  end

  def get_cover(size = :x300)
    if ozon_coverid.present?
      Book.ozon_cover(ozon_coverid, size)
    else
       read_attribute("coverpath_#{size}") || "/covers/missing_#{size}.gif"
    end
  end

  def authors_list
    return @authorslist if @authorslist.present?

    @authorslist = ''
    authors[0..1].each do |author|
      @authorslist += author.short + ', '
    end
    @authorslist.chomp!(', ')
    @authorslist += ' и др.' if authors.length > 2
    @authorslist
  end

  # for specs only! to check DB sort by authors names
  def authorstring
    @authorstring ||= self.authors.collect { |a| a.last }.sort.to_sentence(:last_word_connector => ' и ')
    @authorstring
  end

  # returns 4 books for given *options[:author]* and *options[:title]*
  def self.suggested(options)
    joins(:authors).where('lower(books.title) LIKE lower(:title) AND (lower(authors.full)
        LIKE lower(:authors) OR lower(authors.last) LIKE lower(:authors))', options).
        group('books.id').order('char_length(books.title) ASC, books.id DESC').limit(8)
  end

  def min_price
    read_attribute(:min_price) || 0
  end

  private

  def self.prepare_ts(query = '')
    query.gsub!('|', ' ')
    query.gsub!(':', ' ')
    query.gsub!(/[^\p{Alnum} -]/, '')
    query.squish!
    query.gsub!(/([\p{Alnum}-]+)/) { |m| "#{m}:*" }
    query.gsub!(' ', ' | ')
    query
  end

  # Return an SQL condition for users followed by the given user.
  # We include the user's own id as well
  #def self.followed_by(user)
  #  following_ids = %(SELECT followed_id FROM relationships
  #                    WHERE follower_id = :user_id)
  #  where("user_id IN (#{following_ids}) OR user_id = :user_id",
  #        { :user_id => user })
  #end
end
