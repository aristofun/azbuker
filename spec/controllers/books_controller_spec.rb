# coding: utf-8

require 'spec_helper'

RSpec.describe BooksController, type: :controller do
  include ApplicationHelper
  let(:user) { FactoryBot.create(:user) }

  describe 'Logged in' do
    before(:each) do
      sign_in user
    end

    it 'app helpers check ' do
      expect(ru_debug(user)).to_not be_blank
    end

    context 'test for oz_books suggestion' do
      let!(:book1) { FactoryBot.create(:book_w_author, title: 'ВинограднЫй мозго слизень') }
      let!(:book2) { FactoryBot.create(:book_w_author, title: 'Виноград мозг') }
      let!(:ozbook1) { FactoryBot.create(:oz_book, title: 'Виногр мозг') }
      let!(:ozbook2) { FactoryBot.create(:oz_book, title: 'Виногр омзад') }
      let!(:ozbook3) { FactoryBot.create(:oz_book, title: 'Виногр омза дерко') }
      let!(:ozbook4) { FactoryBot.create(:oz_book, title: 'Виногр омзад ры') }

      it 'should suggest oz_books first if exist' do

        post :suggest, {title: 'виногр', authors: '', format: :js}
        expect(assigns(:books)).to match_array [ozbook1, ozbook2, ozbook4, ozbook3, book2, book1]

        post :suggest, {title: 'виногр ', authors: '', format: :js}
        expect(assigns(:books)).to match_array [ozbook1, ozbook2, ozbook4, ozbook3]

        post :suggest, {title: 'виноград', authors: '', format: :js}
        expect(assigns(:books)).to match_array [book2, book1]
      end
    end

    context 'test for suggestion by title&authorname' do
      let(:author1) { FactoryBot.build(:author, last: 'Иванов', first: 'Михаил') }
      let(:author2) { FactoryBot.build(:author, last: 'Петров') }
      let(:author3) { FactoryBot.create(:author, last: 'Сидоров', first: 'Иван', middle: 'Сергеич') }

      let!(:book1) { FactoryBot.create(:book_w_author, title: '%ВинограднЫй мозг наполеона') }
      let!(:book2) { FactoryBot.create(:book_w_author, title: 'Виноград мозг') }
      let!(:book3) { FactoryBot.create(:book, title: '%ВинограднЫй мозг', authors: [author1]) }
      let!(:book4) { FactoryBot.create(:book, title: 'виногрАдарь', authors: [author1, author2]) }
      let!(:book5) { FactoryBot.create(:book, title: 'Виноградная лоза', authors: [author2, author3]) }

      it 'should retrieve correct book by title&authorname' do
        post :suggest, {title: 'виноград', authors: '', format: :js}
        expect(assigns(:books)).to match_array [book4, book2, book5]

        post :suggest, {title: '%вИногР', authors: '', format: :js}
        expect(assigns(:books)).to match_array [book3, book1]

        post :suggest, {title: 'вИноград', authors: 'Иван', format: :js}
        expect(assigns(:books)).to match_array [book4, book5]

        post :suggest, {title: '', authors: 'Иван Серге', format: :js}
        expect(assigns(:books)).to match_array [book5]

        post :suggest, {title: '', authors: 'Иван', format: :js}
        expect(assigns(:books)).to match_array [book4, book5, book3]

        post :suggest, {title: '', authors: 'мих', format: :js}
        expect(assigns(:books)).to match_array [book4, book3]
      end
    end

    it 'should assign books[] hash' do
      post :suggest, {title: 'qu', authors: 'василий', format: :js}
      expect(response.status).to eq 200
      expect(response).to render_template('suggest')
      expect(assigns(:books)).to match_array []
    end
  end

  it 'should reject unauthenticated requests' do
    post :suggest, {title: 'qu', authors: 'василий'}
    expect(response).to redirect_to(new_user_session_path)
  end

  context 'test for searching' do
    let(:author1) { FactoryBot.build(:author, last: 'Борменталь') }
    let(:author2) { FactoryBot.build(:author, last: 'Эле-Менталь') }

    let!(:book1) { FactoryBot.create(:book, authors: [author1], title: 'Как говорить, чтобы дети слушали. И как слушать, чтобы дети говорили.') }
    let!(:book2) { FactoryBot.create(:book, authors: [author2], title: 'Генератор новых клиентов инструмент') }
    let!(:book12) do
      FactoryBot.create(:book, authors: [author2, author1],
        title: '7 навыков высокоэффективных людей. Мощные инструменты развития личности')
    end
    let!(:book11) { FactoryBot.create(:book, authors: [author1], title: 'Внутри торнадо') }
    let!(:book22) { FactoryBot.create(:book, authors: [author2], title: 'Как завоевывать друзей  и оказывать влияние на людей') }

    it 'should do correct search' do
        10.times do
          FactoryBot.create(:lot, book_id: book1.id, user_id: user.id)
          FactoryBot.create(:lot, book_id: book2.id, user_id: user.id)
          FactoryBot.create(:lot, book_id: book12.id, user_id: user.id)
          FactoryBot.create(:lot, book_id: book11.id, user_id: user.id)
          FactoryBot.create(:lot, book_id: book22.id, user_id: user.id)
        end

        get :search, {q: 'Marginal'}
        expect(response.status).to eq 200
        expect(response).to render_template('search')
        expect(assigns(:books)).to match_array []

        get :search, {q: 'Как говорить'}
        expect(assigns(:books)).to match_array [book1]

        get :search, {q: 'инструменты'}
        expect(assigns(:books)).to match_array [book12, book2]

        get :search, {q: 'новых инструмент'}
        expect(assigns(:books)).to match_array [book2, book12]

        get :search, {q: 'инструменты бормента'}
        expect(assigns(:books)).to match_array [book12, book11, book2, book1]

        get :search, {q: 'Эле-мента'}
        expect(assigns(:books)).to match_array [book22, book12, book2]

        get :search, {q: 'говорить дети слушали эле-'}
        expect(assigns(:books)).to match_array [book1, book22, book12, book2]

        get :search, {q: 'внутри бормента'}
        expect(assigns(:books)).to match_array [book11, book12, book1]
      end
  end
end
