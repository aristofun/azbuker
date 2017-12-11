# coding: utf-8

require 'spec_helper'

describe OzBook do
  before(:each) do
    @ozon_book = OzonBookParser.new(734, nil, Mechanize.new)
    @ozon_book.title = "кувырком"
    @ozon_book.author_last = "миллер"
    @ozon_book.authors_all = "глен миллер, федор шаляпин"
    @ozon_book.genre = 5
    @ozon_book.coverid = "1006679340"
  end

  it "should create himself from OzonBook" do
    @ozon_book.should_skip?.should == false
    @ozon_book.state_valid?.should be_true
    @ozon_book.to_s.should be_present

    expect {
      ozbook = OzBook.create_from_ozon_book!(@ozon_book)
      ozbook.should be_valid
      ozbook.reload
      ozbook.ozonid.should == @ozon_book.bookid
      ozbook.ozon_coverid.should == @ozon_book.coverid
      ozbook.title.should == @ozon_book.title
      ozbook.genre.should == @ozon_book.genre
      ozbook.auth_all.should == @ozon_book.authors_all
      ozbook.auth_last.should == @ozon_book.author_last
    }.to change(OzBook, :count).by(1)
  end

  it "should update by title&auth_all" do
    id = nil
    expect {
      id = OzBook.create_from_ozon_book!(@ozon_book).id
    }.to change(OzBook, :count).by(1)

    ozon_book2 = OzonBookParser.new(223, nil, Mechanize.new)
    ozon_book2.title = "кувырком"
    ozon_book2.author_last = "шаляпин"
    ozon_book2.authors_all = "глен миллер, федор шляпин"
    ozon_book2.genre = 3
    ozon_book2.coverid = "34mb6679340"

    expect {
      ozbook = OzBook.create_from_ozon_book!(ozon_book2)
      ozbook.id.should_not == id
      ozbook.reload
      ozbook.ozonid.should == ozon_book2.bookid
      ozbook.ozon_coverid.should == ozon_book2.coverid
      ozbook.title.should == ozon_book2.title
      ozbook.genre.should == ozon_book2.genre
      ozbook.auth_all.should == ozon_book2.authors_all
      ozbook.auth_last.should == ozon_book2.author_last
    }.to change(OzBook, :count).by(1)

    expect {
      ozbook2 = OzBook.create_from_ozon_book!(@ozon_book)
      ozbook2.id.should == id
    }.to change(OzBook, :count).by(0) # the same coverid

    expect {
      ozon_book2.coverid = "390292349"
      ozbook3 = OzBook.create_from_ozon_book!(ozon_book2)
      ozbook3.id.should_not == id
      ozbook3.ozon_coverid.should == ozon_book2.coverid
      ozbook3.title.should == ozon_book2.title
      ozbook3.genre.should == ozon_book2.genre
      ozbook3.auth_all.should == ozon_book2.authors_all
      ozbook3.auth_last.should == ozon_book2.author_last
    }.to change(OzBook, :count).by(1) # different coverid
  end

end
