# coding: utf-8

require 'spec_helper'
RSpec.describe LotsController, type: :controller do
    let(:user) { FactoryBot.create(:user) }
    let(:user_admin) { FactoryBot.create(:user, :admin) }
    let(:book) { FactoryBot.create(:book_w_author) }

  def lot_attr(authors, book, ozon_coverid = nil)
    FactoryBot.attributes_for(:lot,
                               skypename: "bugaga",
                               cityid: user.cityid,
                               book_title: book[:title],
                               ozonid: 728394,
                               ozon_coverid: ozon_coverid,
                               book_authors: authors,
                               book_genre: book[:genre],
                               cover: fixture_file_upload("/no_resize_original.png", 'image/png', :binary))
  end

  #render_views

  before(:each) do
    sign_in user
  end

  describe "GET index_*" do
    before(:each) { config1 }

    let(:buk) { FactoryBot.create(:book, authors: [@books[3].authors[0]]) }
    let!(:lot) { FactoryBot.create(:lot, book_id: book.id, user_id: @user2.id, cityid: 4) }
    let!(:buk_lot) { FactoryBot.create(:lot, book_id: buk.id) }

    it "index_book redirects if the only lot in current city" do
      get :index_book, {bookid: book.id, cityid: 2}
      expect(response).to render_template 'book'
      expect(assigns(:lots)).to be_empty

      get :index_book, {bookid: book.id, cityid: 4}
      expect(assigns(:lots)).to match_array [lot]
      expect(response).to redirect_to lot_path(lot)
      expect(response.status).to eq 302

      lot_any = FactoryBot.create(:lot, book_id: book.id, user_id: @user2.id, cityid: -1)
      get :index_book, {bookid: book.id, cityid: 4}
      expect(response).to render_template 'book'
      expect(assigns(:lots)).to match_array [lot_any, lot]

      get :index_book, {bookid: book.id, cityid: 1}
      expect(response).to redirect_to lot_path(lot_any)
      expect(response.status).to eq 302
    end

    it "index_book assigns @lots & @another_books" do
      sign_out user

      get :index_book, {bookid: @books[3].id}
      expect(response).to render_template 'book'

      expect(assigns(:book)).to eq @books[3]
      expect(assigns(:lots)).to eq @books[3].lots.active.fresh_first.limit(7).all
      expect(assigns(:another_books)).to match_array [buk, @books[4]]
    end

    it "index_author assigns @books & @author" do
      sign_out user
      get :index_author, {authorid: @author1.id}

      expect(response).to render_template 'author'
      expect(assigns(:author)).to eq @author1
      expect(assigns(:books).sort).to match_array @author1.books.sort
    end

    it "index renders genres" do
      get :index
      expect(response).to render_template 'index'
    end

    it "index_genre assigns @books" do
      get :index_genre, {genreid: @books[2].genre, cityid: -1}
      expect(response).to render_template 'genre'
      bookz = assigns(:books)
      expect(assigns(:books).all).to eq(Book.where('genre = ?', @books[2].genre).present.fresh_first)
    end
  end

  describe "New Lot creation" do

    it "assigns a new lot as @lot" do
      get :new

      expect(assigns(:lot)).to be_a_new(Lot)
      expect(assigns(:lot).cityid).to eq user.cityid
      expect(assigns(:lot).skypename).to eq user.skypename
      expect(assigns(:lot).phone).to eq user.phone
    end

    describe "with valid params" do
      let(:book) { FactoryBot.attributes_for(:book) }
      let(:author1) { FactoryBot.attributes_for(:author) }
      let(:author2) { FactoryBot.attributes_for(:author) }

      it "creates a new Lot with book" do
        lattr = lot_attr(
            "#{author1[:first]} #{author1[:middle]} #{author1[:last]},
             #{author2[:first]} #{author2[:middle]} #{author2[:last]}",
            book, 8394)

        expect {
          expect {
            expect {
              post :create, lot: lattr
            }.to change(Lot, :count).by(1)
          }.to change(Book, :count).by(1)
        }.to change(Author, :count).by(2)

        lot = assigns(:lot)

        expect(lot).to be_persisted
        expect(lot.user).to eq user
        expect(lot.phone).to eq user.phone
        expect(lot.cityid).to eq user.cityid
        expect(lot.comment).to eq lattr[:comment]
        expect(lot.can_deliver).to eq lattr[:can_deliver]
        expect(lot.can_postmail).to eq lattr[:can_postmail]
        expect(lot.price).to eq lattr[:price]
        expect(lot.skypename).to eq lattr[:skypename]

        assigns_book = assigns(:lot).book

        expect(assigns_book.genre).to eq book[:genre]
        expect(assigns_book.title).to eq book[:title]
        expect(assigns_book.authors).to match_array [
                                                            Author.from_string("#{author1[:first]} #{author1[:middle]} #{author1[:last]}"),
                                                            Author.from_string("#{author2[:first]} #{author2[:middle]} #{author2[:last]}")
                                                          ]
        expect(assigns_book.coverpath_x300).to eq lot.cover.url(:x300)
        expect(assigns_book.coverpath_x200).to eq lot.cover.url(:x200)
        expect(assigns_book.coverpath_x120).to eq lot.cover.url(:x120)
        expect(assigns_book.get_cover(:x300)).to eq Book.ozon_cover(lattr[:ozon_coverid])
        expect(assigns_book.get_cover(:x200)).to eq Book.ozon_cover(lattr[:ozon_coverid], :x200)
        expect(assigns_book.ozonid).to eq lattr[:ozonid].to_s
        expect(assigns_book.lots_count).to eq 1
        expect(response).to redirect_to(Lot.last)
      end

      context 'testing creation of lot' do
        let(:author1){ FactoryBot.build(:author) }
        let(:author2){ FactoryBot.build(:author) }
        let(:book) { FactoryBot.create(:book, ozon_coverid: nil, authors: [author1, author2]) }
        let(:book2) { FactoryBot.create(:book, title: book.title, authors: [author1]) }
        let(:book3) { FactoryBot.create(:book, title: book.title, authors: [author2]) }

        it "creates a new Lot for existing book" do
          expect(book.authors.count).to eq 2

          # try to update genre of existing book
          book.genre += 1
          lattr = lot_attr("#{author2.short},#{author1.full}", book)

          expect {
            expect {
              expect {
                post :create, lot: lattr
              }.to change(Lot, :count).by(1)
            }.to change(Book, :count).by(0)
          }.to change(Author, :count).by(0)

          book.reload

          expect(assigns(:lot).book_id).to eq book.id

          assigns_book = assigns(:lot).book

          expect(assigns_book.authors).to match_array [
                                                        Author.from_string("#{author1.short}"),
                                                        Author.from_string("#{author2.full}")
                                                      ]
          expect(assigns_book.genre).to eq book.genre
          expect(assigns_book.lots_count).to eq 1
          expect(assigns_book.get_cover(:x300)).to eq assigns(:lot).cover.url(:x300)
          expect(assigns_book.get_cover(:x200)).to eq assigns(:lot).cover.url(:x200)
          expect(assigns_book.ozon_coverid).to be_blank
          expect(assigns_book.ozonid).to eq lattr[:ozonid].to_s
        end

        let(:book_empty_author) { FactoryBot.create(:book) }

        it "assings default cover URL" do

          lattr = lot_attr("", book_empty_author)
          lattr.delete(:cover)
          expect {
            expect {
              post :create, lot: lattr
            }.to change(Lot, :count).by(1)
          }.to change(Book, :count).by(0)

          lot = assigns(:lot)

          expect(lot.book_id).to eq book_empty_author.id
          expect(lot.cover.url(:x300)).to eq '/covers/missing_x300.png'
          expect(lot.cover).to_not be_present
          expect(book_empty_author.authors).to  be_blank
          expect(response).to redirect_to(Lot.last)
        end


        let(:book1) { book2.dup }
        let(:ozbook) { FactoryBot.create(:oz_book) }
        it "creates new Lot for definite bookid" do

          lattr = lot_attr("#{author1.short}", book1, 7934).merge({ bookid: book2.id })

          expect {
            expect {
              expect {
                post :create, lot: lattr
              }.to change(Lot, :count).by(1)
            }.to change(Book, :count).by(0)
          }.to change(Author, :count).by(0)

          lot = assigns(:lot)
          # lot.reload
          expect(lot.user).to eq user
          expect(lot.comment).to eq lattr[:comment]
          expect(lot.can_deliver).to eq lattr[:can_deliver]
          expect(lot.can_postmail).to eq lattr[:can_postmail]
          expect(lot.price).to eq lattr[:price]
          expect(lot.book).to eq book2
          expect(lot.book.get_cover('300')).to_not eq lot.cover.url(:x300)

          lattr = lot_attr("#{author1.short}Uj", book1, 734).merge({bookid: ozbook.id,
            ozon_flag: ozbook.id, ozonid: 7})

            expect {
              expect {
                post :create, lot: lattr
              }.to change(Lot, :count).by(1)
            }.to change(Book, :count).by(1)

            last_book = Book.last

            expect(last_book.ozon_coverid).to eq '734'
            expect(last_book.ozonid).to eq '7'
            expect(last_book.title).to eq ozbook.title
            expect(last_book.authors.map(&:full).join(' и ')).to eq ozbook.authors_list
            expect(Lot.last.ozon_flag).to be_nil
            expect(Lot.last.book_id).to eq last_book.id
          end
      end


      context 'testing user updation' do
        let(:book) { FactoryBot.build(:book) }
        it "updates user contact_info first time" do
          user.cityid = -1
          user.phone = nil
          user.skypename = nil
          user.save

          lattr = lot_attr("", book).merge({
            skypename: "rspecskyp",
            phone: "495 444 55 66",
            cityid: 7
            })

          post :create, lot: lattr

          lot = assigns(:lot)
          expect(lot.skypename).to eq "rspecskyp"
          expect(lot.phone).to eq "495 444 55 66"
          expect(lot.cityid).to eq 7

          user.reload
          expect(user.skypename).to eq "rspecskyp"
          expect(user.phone).to eq "495 444 55 66"
          expect(user.cityid).to eq 7
        end

        it "does not update user contact_info" do
          old_city = user.cityid
          old_skype = user.skypename
          old_phone = user.phone

          lattr = lot_attr("", book, 7934).merge({
            skypename: "rspecskyp",
            phone: "495 444 55 66",
            cityid: user.cityid + 2
            })
          expect {
            post :create, lot: lattr
          }.to change(Lot, :count).by(1)


          lot = assigns(:lot)

          expect(lot.skypename).to eq "rspecskyp"
          expect(lot.phone).to eq "495 444 55 66"
          expect(lot.cityid).to eq old_city+ 2

          user.reload
          expect(user.skypename).to eq old_skype
          expect(user.phone).to eq old_phone
          expect(user.cityid).to eq old_city
        end
      end
    end

    describe "with invalid params" do
      let(:book) { FactoryBot.attributes_for(:book) }
      it "show :new form for Lot w/o price OR book_title" do
        # Trigger the behavior that occurs when invalid params are submitted
        #Lot.any_instance.stub(:save).and_return(false)
        lattr = lot_attr("   Пушкин", book).merge({ book_title: "" })
        expect {
          expect {
            expect {
              post :create, lot: lattr
            }.to_not change(Lot, :count)
          }.to change(Book, :count).by(0)
        }.to change(Author, :count).by(1)

        pushkin = Author.find_by_last("Пушкин")
        expect(pushkin.books).to be_empty

        expect(assigns(:lot)).to be_a_new(Lot)
        expect(assigns(:lot).errors.get(:book_title)).to_not be_blank
        expect(response).to render_template("new")

        lattr = lot_attr("А. С.  Пушкин", book).merge({price: nil})
        expect {
          expect {
            post :create, lot: lattr
          }.to change(Book, :count).by(1)
        }.to change(Author, :count).by(0)

        pushkin.reload
        expect(Author.find_all_by_last("Пушкин")).to match_array [pushkin]
        expect(pushkin.full).to eq "А С Пушкин"
        expect(pushkin.books[0].title).to eq book[:title]

        expect(assigns(:lot)).to be_a_new(Lot)
        expect(assigns(:lot).errors.get(:price)).to_not be_blank
        expect(response).to render_template("new")
      end

      it "redirects anonymus" do
        sign_out user

        expect do
          post :create, lot: lot_attr("", book)
        end.to_not change(Lot, :count)

        expect(response).to redirect_to new_user_session_path

        get :new
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "GET show" do
    let!(:lot) { FactoryBot.create(:lot, book: book) }
    let!(:lot2) { FactoryBot.create(:lot, book: book, cityid: lot.cityid, user_id: lot.user_id + 1) }
    let!(:lot3) { FactoryBot.create(:lot, book: book, cityid: -1, user_id: lot.user_id + 2) }

    it "assigns the requested lot as @lot" do
      get :show, { id: lot.to_param }
      expect(assigns(:lot)).to eq lot
      expect(assigns(:similar_lots)).to eq [lot3, lot2]
    end
  end


  describe "GET edit" do
    let!(:lot) { FactoryBot.create(:lot, user_id: user.id + 1) }
    let(:users_lot) { FactoryBot.create(:lot, user: user) }

    it "can't edit alien Lot" do
      get :edit, { id: lot.to_param }
      expect(response).to redirect_to show_user_path(user)
    end

    it "only admin can edit alien Lot" do
      sign_in user_admin

      get :edit, { id: lot.to_param }
      expect(response).to be_success
      expect(response).to render_template 'edit'

      expect(assigns(:lot)).to eq lot
    end

    it "assigns the requested lot as @lot" do
      get :edit, { id: users_lot.to_param }
      expect(assigns(:lot)).to eq users_lot
      expect(response).to be_success
    end
  end

  describe "UPDATE" do
    describe "with valid params" do
      let(:lot) { FactoryBot.create(:lot, price: 7, can_deliver: true,
                               can_postmail: true,
                               user: user) }
      let(:attr) { lot.attributes }.freeze

      let(:new_params)  do
        {
          can_deliver: false,
          price: 10,
          book_title: "Кукрыниксы",
          book_id: 777,
          skypename: "muk4",
          can_postmail: false
        }
      end

      it "updates the requested lot" do
        put :update, { id: lot, lot: new_params }

        expect(response).to redirect_to lot

        lt = Lot.find(lot.id)
        expect(lt.attributes).to_not eq attr

        expect(lt.can_deliver).to be_falsey
        expect(lt.can_postmail).to be_falsey
        expect(lt.price).to eq 10
        expect(lt.phone).to eq user.phone
        expect(lt.book_id).to eq lot.book_id
        expect(lt.skypename).to eq new_params[:skypename]
      end

      let(:another_lot) { FactoryBot.create(:lot) }
      it "can't update alien Lot" do
        put :update, {id: another_lot, lot: {can_deliver: false, price: 10}}
        expect(response).to redirect_to show_user_path(user)
      end

      it "only admin can update any Lot" do
        sign_in user_admin
        lot.phone = '492 111 22 33'
        lot.skypename = '2222'
        lot.save

        expect(lot.phone).to eq '492 111 22 33'
        expect(lot.skypename).to eq '2222'
        expect(lot.skypename).to eq '2222'
        expect(user.phone).to_not eq '492 111 22 33'
        expect(user.skypename).to_not eq '2222'

        put :update, {id: lot.to_param, lot: {can_deliver: false, price: 10,
                                                    phone: user.phone, skypename: user.skypename}}
        expect(response).to redirect_to lot

        lt = Lot.find(lot.id)
        expect(lt.read_attribute(:phone)).to be_nil
        expect(lt.phone).to eq user.phone
        expect(lt.read_attribute(:skypename)).to be_nil
        expect(lt.skypename).to eq user.skypename
      end
    end

    describe "with invalid params" do
      let(:lot) { FactoryBot.create(:lot, user: user) }
      it "re-renders the 'edit' template" do
        put :update, {id: lot, lot: {price: -1}}
        expect(response).to render_template("edit")
        expect(Lot.find(lot.id).price).to be > -1
      end
    end
  end

  describe "DELETE & close" do
    let!(:lot) { FactoryBot.create(:lot, user_id: user.id) }
    let!(:second_lot) { FactoryBot.create(:lot, user_id: user.id + 1 ) }

    it "close own lot" do
      put :close, { id: lot.id }
      expect(response).to redirect_to lot
      expect(Lot.find(lot.id)).to_not be_is_active
    end

    it "can't close alien lot" do
      put :close, { id: second_lot.id }
      expect(response).to redirect_to show_user_path(user)
      expect(Lot.find(lot.id)).to be_is_active
    end

    it "can't delete any lot" do
      expect {
        delete :destroy, { id: lot.to_param }
      }.to change(Lot, :count).by(0)

      expect(response).to redirect_to show_user_path(user)
    end

    it "Admin can delete any lot" do
      sign_in user_admin

      expect {
        delete :destroy, { id: lot.id }
      }.to change(Lot, :count).by(-1)

      expect(response).to redirect_to lots_path
    end

    it "Admin can close any lot" do
      sign_in user_admin

      put :close, { id: lot.id }
      expect(response).to redirect_to lot
      expect(Lot.find(lot.id)).to_not be_is_active
    end
  end
end
