# coding: utf-8
#noinspection RailsChecklist01
class LotsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show, :index_book, :index_genre,
                                                 :index_author]
  before_filter :findlot, :only => [:show, :update, :destroy, :edit, :close]
  before_filter :buildlot, :only => [:create]
  before_filter :set_default_city, :only => [:index, :index_book, :index_genre, :index_author]
  before_filter :clear_backredirect, :except => [:create, :update, :edit, :new]

  # caching
  caches_action :index,
                :cache_path => Proc.new { |c| c.params.merge(:cityid => c.session[:cityid]) },
                #.delete_if { |k, v|
                #  k.starts_with?('utm_')},
                :layout => false,
                :expires_in => 10.minutes,
                :race_condition_ttl => 2.seconds
  #,                :unless => Proc.new { |c| c.request.xml_http_request? }


  #CanCan filters
  check_authorization
  authorize_resource

  # GET /genre/:genreid
  # paginator by 16 books
  def index_genre
    @books = Book.custom({:city => cookies[:cityid],
                          :order_by => params[:order_by],
                          :order_to => params[:order_to],
                          :page => params[:page],
                          :genre => params[:genreid]
                         })

    @genreid = params[:genreid].to_i
    render 'genre'
  end

  # GET /author/:authorid
  # default paginator = 12 books
  def index_author
    @author = Author.find(params[:authorid])
    @books = @author.books.custom({:city => cookies[:cityid],
                                   :order_by => params[:order_by],
                                   :order_to => params[:order_to],
                                   :page => params[:page]})
    render 'author'
  end

  # GET /book/:bookid
  def index_book
    @lots = Lot.custom({:bookid => params[:bookid].to_i,
                        :order_by => params[:order_by],
                        :order_to => params[:order_to],
                        :page => params[:page],
                        :city => cookies[:cityid],
                        :limit => 7})
    @book = @lots[0].try(:book) || Book.find(params[:bookid].to_i)

    @another_books = Book.other_books(@book.authors[0], nil, false,
                                      @book.id).present.fresh_first.limit(3) if @book.authors.present?

    if @lots.length == 1
      redirect_to lot_path(@lots[0])
    else
      render 'book'
    end
  end

  def index
  end

  # GET /lots/1
  def show
    @similar_lots = @lot.similar_lots
    @another_lots = @lot.user.lots.active.fresh_first.includes(:book).
        where("lots.id != ?", @lot.id).limit (8) if @lot.user.present?
  end

  # GET /lots/new
  def new
    @lot = Lot.new
    @lot.cityid = current_user.cityid
    recover_lot_contacts

    # find Book if bookid passed
    @ready_book = Book.find_by_id(params[:bookid])
    populate_virtual_attributes(@lot, @ready_book)
  end

  # GET /lots/1/edit
  def edit
    recover_lot_contacts
    populate_virtual_attributes(@lot)
  end

  # POST /lots
  # POST /lots.json
  def create
    @lot.book_title ||= ''
    @lot.book_authors ||= ''

    @lot.book_title.squish!
    @lot.book_authors.squish!
    @lot.user = current_user
    replace_contactinfo

    book = get_book()
    @lot.book = book

    populate_virtual_attributes(@lot, book)
    if @lot.save
      update_book_cover
      redirect_to @lot, notice: t("activerecord.success.created", :model => Lot.model_name.human)
    else
      @ready_book = book
      flash[:warning] = t("generic_errors.lot_not_saved")
      recover_lot_contacts
      render action: "new"
    end
  end

# PUT /lots/1
# PUT /lots/1.json
  def update
    params[:lot][:phone] = nil if @lot.user.phone == params[:lot][:phone]
    params[:lot][:skypename] = nil if @lot.user.skypename== params[:lot][:skypename]

    if @lot.update_attributes(params[:lot])
      redirect_to @lot, notice: t("activerecord.success.updated", :model => Lot.model_name.human)
    else
      render action: "edit"
    end
  end

# DELETE /lots/1
# DELETE /lots/1.json
  def destroy
    # rollback Book cover
    id = @lot.id
    book = @lot.book
    redirpath = lots_path

    if book.present? && book.coverpath_x300 == @lot.cover.url(:x300)
      book.coverpath_x120 = nil
      book.coverpath_x200 = nil
      book.coverpath_x300 = nil
      book.save
      redirpath = book_path(book)
    end

    @lot.destroy
    redirect_to redirpath, :alert => t("activerecord.success.destroyed",
                                       :model => "Объявление ##{id}")
  end

  def close
    @lot.is_active = (params[:active].present? && param_bool(params[:active]))
    if @lot.save
      note = @lot.is_active? ?
          t("activerecord.success.opened", :model => Lot.model_name.human)
      : t("activerecord.success.closed", :model => Lot.model_name.human)

      redirect_to @lot, notice: note
    else
      render :action => :edit
    end
  end

  private

  def update_book_cover
    if @lot.cover.present?
      @lot.book.coverpath_x300 = @lot.cover.url(:x300)
      @lot.book.coverpath_x200 = @lot.cover.url(:x200)
      @lot.book.coverpath_x120 = @lot.cover.url(:x120)
      @lot.book.save
    end
  end

  def replace_contactinfo
    current_user.phone ||= @lot.phone
    current_user.skypename ||= @lot.skypename
    current_user.cityid = @lot.cityid if (current_user.cityid == -1 && @lot.cityid != -1)
    current_user.save
    @lot.phone = nil if current_user.phone == @lot.phone
    @lot.skypename = nil if current_user.skypename == @lot.skypename
  end

  def get_book
    # book set by autosuggest
    book = Book.find(@lot.bookid) if (@lot.bookid.present? && @lot.ozon_flag.blank?)
    # if OzBook suggested
    if @lot.ozon_flag.present?
      ozb = OzBook.find(@lot.ozon_flag)
      @lot.book_genre = ozb.genre
      @lot.book_title = ozb.title
      @lot.book_authors = ozb.auth_all
    end
    authors = find_authors() if book.nil?
    # try to find book by title & authors
    book ||= get_book_with_authors(authors)
    # try to create new
    if book.nil?
      book = Book.new(:title => @lot.book_title, :genre => @lot.book_genre)
      #add authors to book
      authors << Author.from_string("неизвестный") if authors.blank?
      book.authors = authors
    end
    book.ozon_coverid = @lot.ozon_coverid if @lot.ozon_coverid.present?
    book.ozonid = @lot.ozonid if @lot.ozonid.present?

    #@lot.
    base_error_add(t("generic_errors.lot_booktitle")) unless book.save
    book
  end

  def get_book_with_authors(authors = [])
    book = nil
    if authors.blank? # just get book by title and no authors
      books = Book.where(:title => @lot.book_title).limit(20)
      books.each do |item|
        book = item if (item.authors.blank? && authors.blank?) #|| (item.authors.sort == authors.sort)
      end
    else
      book = Book.other_books(authors, @lot.book_title).fresh_first.first
    end
    book
  end

  # returns array of authors id,
  # also creates authors in DB by name during the search
  def find_authors
    authors = []
    Author.split_string(@lot.book_authors).each do |author|
      authors << Author.from_string(author) if author.present?
    end

    if authors.blank? && @lot.book_authors.present?
      base_error_add(t("generic_errors.lot_bookauthors"))
    end

    authors
  end

  def buildlot
    @lot = Lot.new(params[:lot])
  end

  def findlot
    @lot = Lot.find(params[:id])
  end

  def recover_lot_contacts
    @lot.skypename = current_user.skypename if @lot.read_attribute(:skypename).blank?
    @lot.phone = current_user.phone if @lot.read_attribute(:phone).blank?
  end
end
