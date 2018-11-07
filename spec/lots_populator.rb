module LotsPopulator

  # 5 Books, 5x21 Lots, 2 users, 2 authors, + 3 Lots from @user2 (others by @user1)
  # random author for first 3 books
  def config1
    @user1 = FactoryBot.create(:user)
    @user2 = FactoryBot.create(:user)
    @author1 = FactoryBot.create(:author)
    @author2 = FactoryBot.create(:author)
    @books = []

    3.times do
      @books << FactoryBot.create(:book_w_author)
    end

    # 4th and 5th book from @author1,2 and 1
    @books << FactoryBot.create(:book, :authors => [@author1, @author2])
    @books << FactoryBot.create(:book, :authors => [@author1])

    23.times do
      @books.each do |book|
        FactoryBot.create(:lot, :book_id => book.id, :user_id => @user1.id)
      end
    end

    # first 2 books have additional lots from @user2 and a book with 2 authors
    FactoryBot.create(:lot, :book_id => @books[0].id, :user_id => @user2.id)
    FactoryBot.create(:lot, :book_id => @books[1].id, :user_id => @user2.id)
    FactoryBot.create(:lot, :book_id => @books[3].id, :user_id => @user2.id)
  end

  # @author1 has 15 books 3 lots each (random user, and city)
  # @author2 has 10 other books first 5 the same genre as @author1, second – 2 lots each
  # second 5 books are written together @1 + @2
  def config2
    @author1 = FactoryBot.create(:author)
    @author2 = FactoryBot.create(:author)
    @users = []
    10.times do
      @users << FactoryBot.create(:user)
    end

    5.times do
      book = FactoryBot.create(:book, :authors => [@author1])
      FactoryBot.create(:book, :genre => book.genre, :authors => [@author2])
    end

    @author2.books.each do |book|
      3.times do
        FactoryBot.create(:lot, :book_id => book.id, :user_id => @users.sample.id)
      end
    end

    5.times do
      FactoryBot.create(:book, :authors => [@author2, @author1])
    end

    5.times do
      FactoryBot.create(:book, :authors => [@author1])
    end

    @author1.books.each do |book|
      3.times do
        FactoryBot.create(:lot, :book_id => book.id, :user_id => @users.sample.id)
      end
    end

  end
end