# coding: utf-8

require 'spec_helper'

describe LotsController do
  #render_views

  def lot_attr(authors, book, ozon_coverid = nil)
    FactoryBot.attributes_for(:lot,
                               :skypename => "bugaga",
                               :cityid => @user.cityid,
                               :book_title => book[:title],
                               :ozonid => 728394,
                               :ozon_coverid => ozon_coverid,
                               :book_authors => authors,
                               :book_genre => book[:genre],
                               :cover => fixture_file_upload("/no_resize_original.png",
                                                             'image/png', :binary))
  end

  #render_views

  before(:each) do
    @user = FactoryBot.create(:user)
    @user.confirm!
    sign_in @user
  end

  describe "GET index_*" do
    it "index_book redirects if the only lot in current city" do
      config1
      book = FactoryBot.create(:book_w_author)
      lot = FactoryBot.create(:lot, :book_id => book.id, :user_id => @user2.id, :cityid => 4)

      get :index_book, {:bookid => book.id, :cityid => 2}
      response.should render_template 'book'
      assigns(:lots).should be_empty

      get :index_book, {:bookid => book.id, :cityid => 4}
      assigns(:lots).should == [lot]
      response.should redirect_to lot_path(lot)
      response.status.should == 302

      lot_any = FactoryBot.create(:lot, :book_id => book.id, :user_id => @user2.id, :cityid => -1)
      get :index_book, {:bookid => book.id, :cityid => 4}
      response.should render_template 'book'
      assigns(:lots).should == [lot_any, lot]

      get :index_book, {:bookid => book.id, :cityid => 1}
      response.should redirect_to lot_path(lot_any)
      response.status.should == 302

      get :index_book, {:bookid => book.id, :cityid => -1} # xxx – to reset city-id session value
      #cookies[:cityid] = nil
    end

    it "index_book assigns @lots & @another_books" do
      config1
      sign_out @user

      buk = FactoryBot.create(:book, :authors => [@books[3].authors[0]])
      FactoryBot.create(:lot, :book_id => buk.id)

      get :index_book, {:bookid => @books[3].id}
      response.should render_template 'book'
      book = assigns(:book)
      lots = assigns(:lots)
      an_books = assigns(:another_books)
      book.should == @books[3]
      lots.should == @books[3].lots.active.fresh_first.limit(7).all
      an_books.to_a.should == [buk, @books[4]]
    end

    it "index_author assigns @books & @author" do
      config1
      sign_out @user
      get :index_author, {:authorid => @author1.id}
      response.should render_template 'author'
      books = assigns(:books)
      author = assigns(:author)
      author.should == @author1
      books.sort.should == @author1.books.sort
    end

    it "index renders genres" do
      get :index
      response.should render_template 'index'
    end

    it "index_genre assigns @books" do
      config1

      get :index_genre, {:genreid => @books[2].genre, :cityid => -1}
      response.should render_template 'genre'
      bookz = assigns(:books)
      bookz.all.should eq(Book.where('genre = ?', @books[2].genre).present.fresh_first)
    end
  end

  describe "New Lot creation" do

    it "assigns a new lot as @lot" do
      get :new
      lot = assigns(:lot)
      lot.should be_a_new(Lot)
      lot.cityid.should == @user.cityid
      lot.skypename.should == @user.skypename
      lot.phone.should == @user.phone
    end

    describe "with valid params" do

      it "creates a new Lot with book" do
        book = FactoryBot.attributes_for(:book)
        author1 = FactoryBot.attributes_for(:author)
        author2 = FactoryBot.attributes_for(:author)

        lattr = lot_attr(
            "#{author1[:first]} #{author1[:middle]} #{author1[:last]},
             #{author2[:first]} #{author2[:middle]} #{author2[:last]}",
            book, 8394)

        expect {
          expect {
            expect {
              post :create, :lot => lattr
            }.to change(Lot, :count).by(1)
          }.to change(Book, :count).by(1)
        }.to change(Author, :count).by(2)

        lot = assigns(:lot)
        lot.reload
        lot.should be_persisted
        lot.user.should == @user
        lot.comment.should == lattr[:comment]
        lot.can_deliver.should == lattr[:can_deliver]
        lot.can_postmail.should == lattr[:can_postmail]
        lot.price.should == lattr[:price]
        lot.phone.should == @user.phone
        lot.skypename.should == lattr[:skypename]
        lot.cityid.should == @user.cityid

        lot.book.genre.should == book[:genre]
        lot.book.title.should == book[:title]
        lot.book.authors.should == [
            Author.from_string("#{author1[:first]} #{author1[:middle]} #{author1[:last]}"),
            Author.from_string("#{author2[:first]} #{author2[:middle]} #{author2[:last]}"),
        ]

        lot.book.coverpath_x300.should == lot.cover.url(:x300)
        lot.book.coverpath_x200.should == lot.cover.url(:x200)
        lot.book.coverpath_x120.should == lot.cover.url(:x120)
        lot.book.get_cover(:x300).should == Book.ozon_cover(lattr[:ozon_coverid])
        lot.book.get_cover(:x200).should == Book.ozon_cover(lattr[:ozon_coverid], :x200)
        lot.book.ozonid.should == lattr[:ozonid].to_s
        lot.book.lots_count.should == 1
        response.should redirect_to(Lot.last)
      end

      it "creates a new Lot for existing book" do
        author1 = FactoryBot.create(:author)
        author2 = FactoryBot.create(:author)
        book = FactoryBot.create(:book, :ozon_coverid => nil, :authors => [author1, author2])
        book.authors.count.should == 2
        book2 = FactoryBot.create(:book, :title => book.title, :authors => [author1])
        book3 = FactoryBot.create(:book, :title => book.title, :authors => [author2])

        # try to update genre of existing book
        book.genre += 1
        lattr = lot_attr("#{author2.short},#{author1.full}", book)

        expect {
          expect {
            expect {
              post :create, :lot => lattr
            }.to change(Lot, :count).by(1)
          }.to change(Book, :count).by(0)
        }.to change(Author, :count).by(0)

        book.reload

        lot = assigns(:lot)
        lot.reload
        lot.book.authors.should == [
            Author.from_string("#{author1.short}"),
            Author.from_string("#{author2.full}")
        ]

        lot.book.genre.should == book.genre
        lot.book_id.should == book.id
        lot.book.get_cover(:x300).should == lot.cover.url(:x300)
        lot.book.get_cover(:x200).should == lot.cover.url(:x200)
        lot.book.ozon_coverid.should be_blank
        lot.book.ozonid.should == lattr[:ozonid].to_s
        lot.book.lots_count.should == 1
      end

      it "assings default cover URL" do
        book_empty_author = FactoryBot.create(:book)

        lattr = lot_attr("", book_empty_author)
        lattr.delete(:cover)
        expect {
          expect {
            post :create, :lot => lattr
          }.to change(Lot, :count).by(1)
        }.to change(Book, :count).by(0)

        lot = assigns(:lot)
        lot.reload
        lot.book_id.should == book_empty_author.id
        lot.cover.url(:x300).should == '/covers/missing_x300.png'
        lot.cover.should_not be_present
        book_empty_author.authors.should be_blank
        response.should redirect_to(Lot.last)
      end

      it "creates new Lot for definite bookid" do
        book1 = FactoryBot.create(:book)
        book2 = FactoryBot.create(:book)
        author1 = FactoryBot.create(:author)
        book1.authors << author1
        book2.authors << author1
        book1.save
        book2.save
        book1.reload
        book2.reload

        lattr = lot_attr("#{author1.short}", book1, 7934).merge({:bookid => book2.id})

        expect {
          expect {
            expect {
              post :create, :lot => lattr
            }.to change(Lot, :count).by(1)
          }.to change(Book, :count).by(0)
        }.to change(Author, :count).by(0)

        lot = assigns(:lot)
        lot.reload
        lot.user.should == @user
        lot.comment.should == lattr[:comment]
        lot.can_deliver.should == lattr[:can_deliver]
        lot.can_postmail.should == lattr[:can_postmail]
        lot.price.should == lattr[:price]
        lot.book.should == book2
        lot.book.ozon_coverid.should == '7934'
        lot.book.get_cover('300').should_not == lot.cover.url(:x300)

        ozbook = FactoryBot.create(:oz_book)
        lattr = lot_attr("#{author1.short}Uj", book1, 734).merge({:bookid => ozbook.id,
                                                                  :ozon_flag => ozbook.id, :ozonid => 7})

        expect {
          expect {
            post :create, :lot => lattr
          }.to change(Lot, :count).by(1)
        }.to change(Book, :count).by(1)

        Book.last.ozon_coverid.should == '734'
        Book.last.ozonid.should == '7'
        Book.last.title.should == ozbook.title
        Book.last.authors.map(&:full).join(' и ').should == ozbook.authors_list
        Lot.last.ozon_flag.should be_nil
        Lot.last.book_id.should == Book.last.id

      end

      it "updates user contact_info first time" do
        @user.cityid = -1
        @user.phone = nil
        @user.skypename = nil
        @user.save

        book = FactoryBot.create(:book)
        lattr = lot_attr("", book).merge({
                                             :skypename => "rspecskyp",
                                             :phone => "495 444 55 66",
                                             :cityid => 7
                                         })
        post :create, :lot => lattr

        lot = assigns(:lot)
        lot.skypename.should == "rspecskyp"
        lot.phone.should == "495 444 55 66"
        lot.cityid.should == 7

        @user.reload
        @user.skypename.should == "rspecskyp"
        @user.phone.should == "495 444 55 66"
        @user.cityid.should == 7
      end

      it "don't updates user contact_info" do
        book = FactoryBot.create(:book)
        old_city = @user.cityid
        old_skype = @user.skypename
        old_phone = @user.phone

        lattr = lot_attr("", book, 7934).merge({
                                                   :skypename => "rspecskyp",
                                                   :phone => "495 444 55 66",
                                                   :cityid => @user.cityid + 2
                                               })
        expect {
          post :create, :lot => lattr
        }.to change(Lot, :count).by(1)


        lot = assigns(:lot)

        lot.skypename.should == "rspecskyp"
        lot.phone.should == "495 444 55 66"
        lot.cityid.should == old_city+ 2

        @user.reload
        @user.cityid.should == old_city
        @user.skypename.should == old_skype
        @user.phone.should == old_phone
      end
    end

    describe "with invalid params" do

      it "show :new form for Lot w/o price OR book_title" do
        # Trigger the behavior that occurs when invalid params are submitted
        #Lot.any_instance.stub(:save).and_return(false)
        book = FactoryBot.attributes_for(:book)
        lattr = lot_attr("   Пушкин", book).merge({:book_title => ""})
        expect {
          expect {
            expect {
              post :create, :lot => lattr
            }.to_not change(Lot, :count)
          }.to change(Book, :count).by(0)
        }.to change(Author, :count).by(1)

        pushkin = Author.find_by_last("Пушкин")
        pushkin.books.should be_empty

        assigns(:lot).should be_a_new(Lot)
        assigns(:lot).errors.get(:book_title).should_not be_blank
        response.should render_template("new")

        lattr = lot_attr("А. С.  Пушкин", book).merge({:price => nil})
        expect {
          expect {
            post :create, :lot => lattr
          }.to change(Book, :count).by(1)
        }.to change(Author, :count).by(0)

        pushkin.reload
        Author.find_all_by_last("Пушкин").should == [pushkin]
        pushkin.full.should == "А С Пушкин"
        pushkin.books[0].title.should == book[:title]

        assigns(:lot).should be_a_new(Lot)
        assigns(:lot).errors.get(:price).should_not be_blank
        response.should render_template("new")
      end

      it "redirects anonymus" do
        sign_out @user
        book = FactoryBot.create(:book)
        expect do
          post :create, :lot => lot_attr("", book)
        end.to_not change(Lot, :count)

        response.should redirect_to new_user_session_path

        get :new
        response.should redirect_to new_user_session_path
      end
    end
  end

  describe "GET show" do
    it "assigns the requested lot as @lot" do
      book = FactoryBot.create(:book_w_author)
      lot = FactoryBot.create(:lot, :book => book)
      lot2 = FactoryBot.create(:lot, :book => book, :cityid => lot.cityid,
                                :user_id => lot.user_id + 1)

      sleep 0.1

      lot3 = FactoryBot.create(:lot, :book => book, :cityid => -1,
                                :user_id => lot.user_id + 2)

      get :show, {:id => lot.to_param}
      assigns(:lot).should eq(lot)
      assigns(:similar_lots).should eq([lot3, lot2])
    end
  end


  describe "GET edit" do

    it "can't edit alien Lot" do
      lot = FactoryBot.create(:lot, :user_id => @user.id + 1)

      get :edit, {:id => lot.to_param}
      response.should redirect_to show_user_path(@user)

    end

    it "only admin can edit alien Lot" do
      lot = FactoryBot.create(:lot, :user_id => @user.id + 1)
      @user.update_column(:admin, true)

      get :edit, {:id => lot.to_param}
      response.should be_success
      response.should render_template 'edit'

      assigns(:lot).should eq(lot)
    end

    it "assigns the requested lot as @lot" do
      lot = FactoryBot.create(:lot, :user => @user)
      get :edit, {:id => lot.to_param}
      assigns(:lot).should eq(lot)
      response.should be_success
    end
  end

  describe "UPDATE" do
    describe "with valid params" do
      it "updates the requested lot" do
        lot = FactoryBot.create(:lot, :price => 7, :can_deliver => true,
                                 :can_postmail => true,
                                 :user_id => @user.id)
        attr = lot.attributes.freeze
        #Lot.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => lot.id, :lot => {
            :can_deliver => false, :price => 10,
            :book_title => "Кукрыниксы", :book_id => 777,
            :skypename => "muk4",
            :can_postmail => false
        }
        }

        response.should redirect_to lot

        lt = Lot.find(lot.id)
        lt.attributes.should_not == attr

        lt.can_deliver.should be_falsey
        lt.can_postmail.should be_falsey
        lt.price.should == 10
        lt.phone.should == @user.phone
        lt.book_id.should == lot.book_id
        lt.skypename.should == "muk4"
      end

      it "can't update alien Lot" do
        lot = FactoryBot.create(:lot, :user_id => @user.id + 1)
        put :update, {:id => lot.to_param, :lot => {:can_deliver => false, :price => 10}}
        response.should redirect_to show_user_path(@user)
      end

      it "only admin can update any Lot" do
        user = FactoryBot.create(:user)
        lot = FactoryBot.create(:lot, :user => user, :phone => '492 111 22 33',
                                 :skypename => '2222')
        @user.update_column(:admin, true)

        lot.reload
        lot.phone.should == '492 111 22 33'
        lot.skypename.should == '2222'
        user.phone.should_not == '492 111 22 33'
        user.skypename.should_not == '2222'

        put :update, {:id => lot.to_param, :lot => {:can_deliver => false, :price => 10,
                                                    :phone => user.phone, :skypename => user.skypename}}
        response.should redirect_to lot
        lt = Lot.find(lot.id)
        lt.read_attribute(:phone).should be_nil
        lt.phone.should == user.phone
        lt.read_attribute(:skypename).should be_nil
        lt.skypename.should == user.skypename
      end
    end

    describe "with invalid params" do
      it "re-renders the 'edit' template" do
        lot = FactoryBot.create(:lot, :user_id => @user.id)
        put :update, {:id => lot.to_param, :lot => {:price => -1}}
        response.should render_template("edit")
        Lot.find(lot.id).price.should > -1
      end
    end
  end

  describe "DELETE & close" do

    it "close own lot" do
      lot = FactoryBot.create(:lot, :user_id => @user.id)
      put :close, {:id => lot.id}
      response.should redirect_to lot
      Lot.find(lot.id).is_active.should be_falsey
    end

    it "can't close alien lot" do
      lot = FactoryBot.create(:lot, :user_id => @user.id + 1)
      put :close, {:id => lot.id}
      response.should redirect_to show_user_path(@user)
      Lot.find(lot.id).is_active.should be_truthy
    end

    it "can't delete any lot" do
      lot = FactoryBot.create(:lot, :user => @user)
      expect {
        delete :destroy, {:id => lot.to_param}
      }.to change(Lot, :count).by(0)

      response.should redirect_to show_user_path(@user)
    end

    it "Admin can delete any lot" do
      lot = FactoryBot.create(:lot, :user_id => @user.id + 1)
      @user.update_column(:admin, true)
      expect {
        delete :destroy, {:id => lot.id}
      }.to change(Lot, :count).by(-1)

      response.should redirect_to lots_path
    end

    it "Admin can close any lot" do
      lot = FactoryBot.create(:lot, :user_id => @user.id + 1)
      @user.update_column(:admin, true)
      put :close, {:id => lot.id}
      response.should redirect_to lot
      Lot.find(lot.id).is_active.should be_falsey
    end
  end
end
