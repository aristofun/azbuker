# coding: utf-8

require 'spec_helper'

describe BooksController do
  include ApplicationHelper

  describe 'Logged in' do
    before(:each) do
      @user = FactoryBot.create(:user)
      @user.confirm!
      sign_in @user
    end

    it 'app helpers check ' do
      ru_debug(@user).should_not be_blank
    end

    it 'should suggest oz_books first if exist' do
      book1 = FactoryBot.create(:book_w_author, :title => 'ВинограднЫй мозго слизень')
      book2 = FactoryBot.create(:book_w_author, :title => 'Виноград мозг')
      ozbook1 = FactoryBot.create(:oz_book, :title => 'Виногр мозг')
      ozbook2 = FactoryBot.create(:oz_book, :title => 'Виногр омзад')
      ozbook3 = FactoryBot.create(:oz_book, :title => 'Виногр омза дерко')
      ozbook4 = FactoryBot.create(:oz_book, :title => 'Виногр омзад ры')

      post :suggest, {:title => 'виногр', :authors => '', :format => :js}
      assigns(:books).should == [ozbook1, ozbook2, ozbook4, ozbook3, book2, book1]

      post :suggest, {:title => 'виногр ', :authors => '', :format => :js}
      assigns(:books).should == [ozbook1, ozbook2, ozbook4, ozbook3]

      post :suggest, {:title => 'виноград', :authors => '', :format => :js}
      assigns(:books).should == [book2, book1]
    end

    it 'should retrieve correct book by title&authorname' do
      author1 = FactoryBot.create(:author, :last => 'Иванов', :first => 'Михаил')
      author2 = FactoryBot.create(:author, :last => 'Петров')
      author3 = FactoryBot.create(:author, :last => 'Сидоров', :first => 'Иван',
                                   :middle => 'Сергеич')
      book1 = FactoryBot.create(:book_w_author, :title => '%ВинограднЫй мозг наполеона')
      book2 = FactoryBot.create(:book_w_author, :title => 'Виноград мозг')
      book3 = FactoryBot.create(:book, :title => '%ВинограднЫй мозг', :authors => [author1])
      book4 = FactoryBot.create(:book, :title => 'виногрАдарь', :authors => [author1, author2])
      book5 = FactoryBot.create(:book, :title => 'Виноградная лоза', :authors => [author2,
                                                                                   author3])

      post :suggest, {:title => 'виноград', :authors => '', :format => :js}
      assigns(:books).should == [book4, book2, book5]

      post :suggest, {:title => '%вИногР', :authors => '', :format => :js}
      assigns(:books).should == [book3, book1]

      post :suggest, {:title => 'вИноград', :authors => 'Иван', :format => :js}
      assigns(:books).should == [book4, book5]

      post :suggest, {:title => '', :authors => 'Иван Серге', :format => :js}
      assigns(:books).should == [book5]

      post :suggest, {:title => '', :authors => 'Иван', :format => :js}
      assigns(:books).should == [book4, book5, book3]

      post :suggest, {:title => '', :authors => 'мих', :format => :js}
      assigns(:books).should == [book4, book3]
    end

    it 'should assign books[] hash' do
      post :suggest, {:title => 'qu', :authors => 'василий', :format => :js}
      response.should be_success
      response.should render_template('suggest')
      books = assigns(:books)
      books.should == []
    end
  end

  it 'should reject unauthenticated requests' do
    post :suggest, {:title => 'qu', :authors => 'василий'}
    response.should redirect_to(new_user_session_path)
  end

  it 'should do correct search' do
    @user1 = FactoryBot.create(:user)
    @author1 = FactoryBot.create(:author, :last => 'Борменталь')
    @author2 = FactoryBot.create(:author, :last => 'Эле-Менталь')
    @book1 = FactoryBot.create(:book, :authors => [@author1], :title => 'Как говорить, чтобы дети слушали. И как слушать, чтобы дети говорили.')
    @book2 = FactoryBot.create(:book, :authors => [@author2], :title => 'Генератор новых клиентов инструмент')
    @book12 = FactoryBot.create(:book, :authors => [@author2, @author1],
                                 :title => '7 навыков высокоэффективных людей. Мощные инструменты развития личности')
    @book11 = FactoryBot.create(:book, :authors => [@author1], :title => 'Внутри торнадо')
    @book22 = FactoryBot.create(:book, :authors => [@author2], :title => 'Как завоевывать друзей  и оказывать влияние на людей')

    10.times do
      FactoryBot.create(:lot, :book_id => @book1.id, :user_id => @user1.id)
      FactoryBot.create(:lot, :book_id => @book2.id, :user_id => @user1.id)
      FactoryBot.create(:lot, :book_id => @book12.id, :user_id => @user1.id)
      FactoryBot.create(:lot, :book_id => @book11.id, :user_id => @user1.id)
      FactoryBot.create(:lot, :book_id => @book22.id, :user_id => @user1.id)
    end

    get :search, {:q => 'Marginal'}
    response.should be_success
    response.should render_template('search')
    books = assigns(:books)
    books.should == []

    get :search, {:q => 'Как говорить'}
    assigns(:books).should == [@book1]

    get :search, {:q => 'инструменты'}
    assigns(:books).should == [@book12, @book2]

    get :search, {:q => 'новых инструмент'}
    assigns(:books).should == [@book2, @book12]

    get :search, {:q => 'инструменты бормента'}
    assigns(:books).should == [@book12, @book11, @book2, @book1]

    get :search, {:q => 'Эле-мента'}
    assigns(:books).should == [@book22, @book12, @book2]

    get :search, {:q => 'говорить дети слушали эле-'}
    assigns(:books).should == [@book1, @book22, @book12, @book2]

    get :search, {:q => 'внутри бормента'}
    assigns(:books).should == [@book11, @book12, @book1]
  end
end
