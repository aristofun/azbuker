# coding: utf-8
require 'spec_helper'

describe Book do

  it "should get correct other books" do
    book1 = FactoryBot.create(:book_w_author, :title => 'mein kampf')
    auth1 = book1.authors[0]
    auth2 = FactoryBot.create(:author)
    book2 = FactoryBot.create(:book, :authors => [auth2], :title => 'mein kampf')
    book3 = FactoryBot.create(:book, :authors => [auth2, auth1], :title => 'mein kampf')

    Book.count.should == 3
    Author.count.should == 2

    Book.other_books([auth1.id, auth2.id], 'mein kampf').should == [book3]
    Book.other_books([auth2.id], 'mein kampf').should == [book2]
    Book.other_books([auth1.id], 'mein kampf').should == [book1]
  end

  it "should correctly process string for fulltext search" do
    Book.prepare_ts("ты нах: чо**dfot такой?").should == 'ты:* | нах:* | чоdfot:* | такой:*'
  end

  it "should get correst coverpath value" do
    book = FactoryBot.create(:book) # with ozon_coverid
    book.get_cover.should == "http://static.ozone.ru/multimedia/books_covers/#{book.ozon_coverid}.jpg"
    book.get_cover(:x300).should == "http://static.ozone.ru/multimedia/books_covers/#{book.ozon_coverid}.jpg"
    book.get_cover(:x200).should == "http://static.ozone.ru/multimedia/books_covers/c200/#{book.ozon_coverid}.jpg"
    book.get_cover(:x120).should == "http://static.ozone.ru/multimedia/books_covers/c120/#{book.ozon_coverid}.jpg"

    book2 = FactoryBot.create(:book, :ozon_coverid => nil, :coverpath_x300 => "path300.jpg",
                               :coverpath_x120 => nil)
                                     #puts book2.inspect
    book2.get_cover.should == "path300.jpg"
    book2.get_cover(:x300).should == "path300.jpg"
    book2.get_cover(:x200).should == book2.coverpath_x200
    book2.coverpath_x120.should be_nil
    book2.get_cover(:x120).should == "/covers/missing_x120.gif"
  end

  it "should create valid object" do
    lambda do
      FactoryBot.create(:book, :title => "Ж"*255).should be_valid
      FactoryBot.build(:book, :title => "Ж"*256).should_not be_valid
      FactoryBot.create(:book, :title => "Ж"*1).should be_valid
      FactoryBot.build(:book, :title => " \t \n  ").should_not be_valid
      FactoryBot.create(:book, :title => "Ж"*1, :genre => 7).should be_valid
      FactoryBot.build(:book, :title => " Пук", :genre => 8).should_not be_valid
    end.should change(Book, :count).by(3)
  end

  it "should create correct author-book id link" do
    lambda do
      book0 = FactoryBot.create(:book)
      book0.should be_valid
      book0.authors.should == []
      book0.genre.should >= -1

      book = FactoryBot.create(:book_w_author, :genre => 2)
      book.should be_valid
      book.authors.length.should == 1
      book.genre.should == 2

      auth = FactoryBot.create(:author)
      book2 = FactoryBot.create(:book, :authors => [auth])
      auth.books.should == [book2]
      book2.authors.should == [auth]

      book0.authors << auth
      book0.save
      book0.should be_valid
      book0.authors.should == [auth]
      auth.reload
      auth.should be_valid
      auth.books.sort.should == [book2, book0].sort

      auth2 = FactoryBot.create(:author, :books => [book0])
      book0.reload
      book0.authors.sort.should == [auth, auth2].sort
      auth2.books.should == [book0]
      auth2.books << book2
      auth2.save
      auth2.books.sort.should == [book0, book2].sort
      book2.reload
      book2.authors.sort.should == [auth, auth2].sort

      book2.authors_list.should == "#{auth.short}, #{auth2.short}"
    end.should change(Book, :count).by(3)
  end
end
