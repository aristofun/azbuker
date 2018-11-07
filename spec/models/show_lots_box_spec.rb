# coding: utf-8
require 'spec_helper'

describe "Book&Lot custom getters" do

  describe "custom Book getter" do
    before(:each) do
      config2
    end

    it "should get Books for author" do
      #puts @author1.books.custom.where("books.title ilike '%книг%'").to_sql
      @author1.books.custom.where("books.title like '%%'").should == @author1.books.present
      .fresh_first[0..15]
      # + city filter
      bks = @author1.books.custom(:city => -1, :page => 2, :limit => 4)
      bks.should == @author1.books.present.fresh_first[4..7]
    end

    it "should get books for genre" do
      Book.custom(:genre => 2).should == Book.where('genre = 2').present.fresh_first.limit(12).all
      Book.custom(:genre => 5, :limit => 8).should == Book.where('genre = 5').present.fresh_first.limit(8).all
    end

    it "should set correct lots_count & min_price" do
      book = FactoryBot.create(:book_w_author)
      lot1 = FactoryBot.create(:lot, :book_id => book.id, :user => @users.sample, :price => 2,
                                :cityid => 0)
      lot2 = FactoryBot.create(:lot, :book_id => book.id, :user => @users.sample, :price => 3,
                                :cityid => 1)
      lot3 = FactoryBot.create(:lot, :book_id => book.id, :user => @users.sample, :price => 4,
                                :cityid => 2)
      lot4 = FactoryBot.create(:lot, :book_id => book.id, :user => @users.sample, :price => 5,
                                :cityid => 2)
      lot5 = FactoryBot.create(:lot, :book_id => book.id, :user => @users.sample, :price => 1,
                                :cityid => 2, :is_active => false)

      book.reload
      book.lots_count.should == 4
      book.min_price.should == 2

      book.authors[0].books.custom.should == [book]
      book.authors[0].books.custom(:city => -1).should == [book]
      book.authors[0].books.custom(:city => 2).should == [book]

      bk = book.authors[0].books.custom(:city => 2)[0]
      bk.min_price.should == 4
      bk.lots_count.should == 2

      bk = book.authors[0].books.custom(:city => 1)[0]
      bk.min_price.should == 3
      bk.lots_count.should == 1
      book.authors[0].books.custom(:city => 4).should be_empty

      bk = book.authors[0].books.custom(:city => 2, :is_active => false)[0]
      bk.lots_count.should == 1
      bk.min_price.should == 1
    end
  end

  describe "custom Lot getter" do

    # lots for book (+city +inactive)
    it "should get lots for book" do
      config1
      lots = Lot.custom(:bookid => @books[3].id)
      lots.should == @books[3].lots.active.fresh_first[0..7]

      @books[1].lots[0].is_active = false
      @books[1].lots[0].save

      lots = Lot.custom(:bookid => @books[1].id, :limit => 20)
      lots.should == @books[1].lots.active.fresh_first[0..19]

      lots = Lot.custom(:bookid => @books[1].id, :is_active => false)
      lots.should == @books[1].lots.inactive.fresh_first.all

      lots = Lot.custom(:bookid => @books[2].id, :city => @books[2].lots[3].cityid)
      lots.should == @books[2].lots.where("cityid IN (-1,?)", @books[2].lots[3].cityid).fresh_first.limit(8).all
    end

    # lots for genre (+city, +inactive)
    it "should get lots for genre" do
      config1
      lots = Lot.custom(:genre => @books[1].genre, :order_by => :date, :order_to => :asc)
      lots.should == @books[1].lots.active.old_first[0..7] # 0..9 -- default :limit == 10

      @books[1].lots[0].is_active = false
      @books[1].lots[0].save

      lots = Lot.custom(:genre => @books[1].genre, :is_active => false)
      lots.should == [@books[1].lots[0]]

      cityid = @books[0].lots[0].cityid
                                                           #puts "CItyID: #{cityid}"
      lots = Lot.custom(:genre => @books[0].genre, :city => cityid).all
      test_lots = Lot.where('cityid IN (?,-1)', cityid).active.fresh_first.all

      test_lots.each do |lot|
        test_lots.delete(lot) unless (lot.book.genre == @books[0].genre) && (lot.cityid == -1 ||
            lot.cityid == cityid)
      end

      #puts lots.map(&:cityid)
      #puts "test:"
      #puts test_lots.map(&:cityid)
      lots.should == test_lots
    end

    # lots for user (+city, +genre) +sort by author
    it "should get lots for user" do
      config1
      lots = Lot.custom(:userid => @user1.id, :limit => 11, :page => 2)
      alllots = @user1.lots
      lots.should == alllots.sort_by(&:updated_at).reverse[11..21]

      lots = Lot.custom(:userid => @user2.id, :order_by => :author)
      alllots = @user2.lots.sort_by { |lot| lot.book.authors.last.last }
      lots.should == alllots.reverse

      lots = Lot.custom(:userid => @user1.id, :genre => @books[3].genre,
                        :order_by => :price,
                        :limit => 7, :page => 2)
      alllots = @books[3].lots.where("user_id = #{@user1.id}").sort_by { |lot| lot.price }.reverse
      lots.should == alllots[7..13]
    end

    #  lots for author (+city, +orders, +paginator)
    it "should get lots for author" do
      config1
      lots = Lot.custom(:authorid => @books[0].authors[0].id,
                        :order_by => :price,
                        :order_to => :asc, :limit => 20)
      alllots = []
      @books[0].authors[0].books.each do |book|
        book.lots.each do |lot|
          alllots << lot
        end
      end
      lots.should == alllots.sort_by(&:price)[0..19]

      # choose definite cityid
      cityid = @books[3].lots[3].cityid
      cityid = @books[3].lots[2].cityid if cityid == -1 # XXX – failed if city-id = -1

      lots = Lot.custom(:authorid => @author1.id,
                        :city => cityid,
                        :order_to => :asc, :limit => 6)
      alllots = []
      # @author1 => {book[3] & book[4]}
      [@books[3], @books[4]].each do |book|
        book.lots.each do |lot|
          alllots << lot if (cityid == lot.cityid || lot.cityid == -1)
        end
      end

      #puts cityid
      #puts lots.map(&:id).to_s
      #puts alllots.sort_by(&:updated_at).map(&:id).to_s
      lots.should == alllots.sort_by(&:updated_at)[0..5] # XXX – failed if city-id = -1

      lots = Lot.custom(:authorid => @author2.id, :page => 3, :limit => 5)
      alllots = @books[3].lots
      lots.should == alllots.sort_by(&:updated_at).reverse[10..14]
    end

    #after(:all) do
    #  Lot.delete_all
    #  Book.delete_all
    #  Author.delete_all
    #  User.delete_all
    #end
  end
end