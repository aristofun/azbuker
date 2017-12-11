# coding: utf-8
class OzBook < ActiveRecord::Base
  attr_accessible :auth_all, :auth_last, :genre, :ozon_coverid, :ozonid, :title

  validates :genre, :numericality => {:only_integer => true}
  validates :ozonid, :presence => true, :numericality => {:only_integer => true}

  validates :title,
            :presence => true,
            :allow_blank => false,
            :length => {:maximum => 255}

  validates :auth_all,
            :presence => true,
            :allow_blank => false,
            :length => {:maximum => 255}

  validates :auth_last,
            :presence => true,
            :allow_blank => true,
            :length => {:maximum => 255}

  def self.create_from_ozon_book!(ozon_book)
    ozbook = OzBook.where(
        "lower(oz_books.title) = lower(?) AND lower(oz_books.auth_all) = lower(?) AND oz_books.ozon_coverid = ?",
        ozon_book.title, ozon_book.authors_all, ozon_book.coverid).last
#    SELECT "oz_books".* FROM "oz_books" WHERE (lower(oz_books.title) = lower('g') AND lower(oz_books.auth_all) = lower('HG') AND oz_books.ozon_coverid = '1000586064') ORDER BY "oz_books"."id" DESC LIMIT 1
    ozbook ||= OzBook.new

    ozbook.update_attributes!(
        :title => ozon_book.title,
        :auth_last => ozon_book.author_last,
        :auth_all => ozon_book.authors_all,
        :genre => ozon_book.genre,
        :ozonid => ozon_book.bookid,
        :ozon_coverid => ozon_book.coverid
    )
    ozbook
  end

  # returns 4 books for given *options[:author]* and *options[:title]*
  def self.suggested(options)
    where("lower(oz_books.title) LIKE lower(:title) AND (lower(oz_books.auth_all) LIKE
lower(:authors) OR lower(oz_books.auth_last) LIKE lower(:authors))", options).
        order('char_length(oz_books.title) ASC, oz_books.id DESC').limit(8)
  end

  def get_cover(size)
    Book.ozon_cover(ozon_coverid, size)
  end

  def authors_list
    return @authors_list if @authors_list.present?

    authors = Author.split_string(auth_all)
    if authors.length > 2
      authors = authors[0..1]
      authors << "др."
    end
    @authors_list = authors.to_sentence(:last_word_connector => ' и ',
                                        :two_words_connector => ' и ')
  end
end
