# coding: utf-8
ActiveAdmin.register Book do
  before_filter :only => :index do
    @per_page = 50
  end


  scope :all
  scope :present
  scope :absent
  scope :unauthored

  member_action :add_author, :method => :post do
    Book.find(params[:id]).authors << Author.from_string("неизвестен")
    flash[:notice] = "Неизвестен автор добавлен в книгу #{params[:id]}"
    redirect_to(:action => :index, :scope => :unauthored)
  end


  filter :id
  filter :title
  filter :lots_count
  filter :min_price
  filter :updated_at
  filter :created_at

  index do
    selectable_column
    column :id
    column :title, :sortable => :title do |book|
      link_to book.title, book_path(book)
    end
    column :lots_count
    column :min_price
    column :authors_count do |book|
      cnt = book.authors.count
      if cnt > 0
        cnt
      else
        link_to(book.authors.count, add_author_odminko_book_path(book), :method => :post)
      end
    end

    column :cover do |book|
      image_tag(book.get_cover(:x120), :size => '48x48')
    end

    column :updated_at

    default_actions
  end
end
