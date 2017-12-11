ActiveAdmin.register OzBook do
  before_filter :only => :index do
    @per_page = 100
  end

  filter :id
  filter :title
  filter :auth_last
  filter :auth_all
  filter :genre
  filter :ozonid

  index do
    selectable_column

    column :id, :sortable => :id do |book|
      link_to book.id, odminko_oz_book_path(book)
    end
    column :title

    column :ozonid, :sortable => :ozonid do |book|
      link_to book.ozonid, "#{Globals::OZON_URL}#{book.ozonid}/"
    end

    column :cover do |book|
      url = Book.ozon_cover(book.ozon_coverid, :x120)
      link_to(image_tag(url, :size => '48x48'), url)
    end

    column :genre
    column :auth_last
    column :auth_all

    default_actions
  end
end
