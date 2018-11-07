# coding: utf-8

require 'spec_helper'

describe "Lots" do
  describe "GET /lots" do

    it "/new shows good new Lot form" do
      config1
      visit new_lot_path # not logged in
      page.current_path.should == new_user_session_path

      login(FactoryBot.create(:user)) # redirect back after login
      page.current_path.should == new_lot_path

      page.should have_xpath("//form[@id='new_lot'][@action='#{lots_path}']", :count => 1)
      page.should have_xpath("//input[@id='lot_book_title']", :count => 1)
      page.should have_xpath("//input[@id='lot_book_authors']", :count => 1)
      page.should have_xpath("//select[@id='lot_book_genre']", :count => 1)
      page.should have_xpath("//input[@id='lot_cover']", :count => 1)
      page.should have_xpath("//input[@id='lot_price']", :count => 1)
      page.should have_xpath("//select[@id='lot_cityid']", :count => 1)
      page.should have_xpath("//textarea[@id='lot_comment']", :count => 1)
    end

    it "user/:id shows lots list w. paginator" do
      config1
      numlots = @user1.lots.active.count

      visit show_user_path(@user1)

      page.should have_xpath("//form[@id='genre_filter_form']", :count => 1)
      page.should match_selector_content("div.dateprice-chooser a", 'по дате')
      page.should match_selector_content("div.dateprice-chooser a", 'по цене')
      page.should match_selector_content("div.dateprice-chooser a", 'по автору')

      # must have pagination from 1 to numlots/per_page=8 count
      page.should have_xpath("//div[@class='pagination']//a[contains(@href,'page=1')]")
      page.should have_xpath("//div[@class='pagination']//a[contains(@href,'page=#{(numlots/14.0).ceil}')]")
    end

    it "book/:bookid" do
      config1
      numlots = @books[3].lots.active.count

      visit book_path(@books[3].id)
      page.current_path.should == book_path(@books[3].id)
      page.should have_xpath("//form[@id='city_filter_form']", :count => 1)
      page.should match_selector_content("div.dateprice-chooser a", 'по дате')
      page.should match_selector_content("div.dateprice-chooser a", 'по цене')
      page.should have_no_selector("div.dateprice-chooser a", :text => 'по автору')
      page.should have_selector("div#micro_lot", :count => 7)

      # must have pagination from 1 to numlots/per_page=7 count
      page.should have_xpath("//div[@class='pagination']//a[contains(@href,'page=1')]")
      page.should have_xpath("//div[@class='pagination']//a[contains(@href,'page=#{(numlots/7.0).ceil}')]")

      #another books (1 book = @books[4])
      #puts page.body
      #print Book.all.map(&:genre)
      #p 'wtf'
      #print Author.all.map(&:id)
      #User.all.map(&:id)
      unless page.has_selector?("p#another_book", :count => 1)
        print Book.all.map(&:genre)
        print Book.all.map(&:id)
        print Lot.all.map(&:id)
      end
    end

    it "author/:authorid" do
      config1
      numbooks = @books[3].authors[0].books.count

      visit author_path(@books[3].authors[0].id)
      page.current_path.should == author_path(@books[3].authors[0].id)
      page.should match_selector_content("h3", @books[3].authors[0].full)
      page.should have_xpath("//form[@id='city_filter_form']", :count => 1)
      page.should match_selector_content("div.dateprice-chooser a", 'по дате')
      page.should match_selector_content("div.dateprice-chooser a", 'по цене')
      page.should have_no_selector("div.dateprice-chooser a", :text => 'по автору')
      page.should have_selector("div#big_book", :count => numbooks)
    end

    it "genre/:genreid" do
      config1
      numbooks = Book.where('genre = ?', @books[1].genre).count

      visit genre_path(@books[1].genre)
      page.current_path.should == genre_path(@books[1].genre)
      page.should match_selector_content("h2", Globals::GENRES[@books[1].genre])
      page.should have_xpath("//form[@id='city_filter_form']", :count => 1)
      page.should match_selector_content("div.dateprice-chooser a", 'по дате')
      page.should match_selector_content("div.dateprice-chooser a", 'по цене')
      page.should have_selector("div.dateprice-chooser a", :text => 'по автору')
      page.should have_selector("div#big_book", :count => numbooks)
    end
  end

  after(:all) do
    print Lot.count
    print Book.count
    print Author.count
    print User.count
  end
end
