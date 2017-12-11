ActiveAdmin.register Lot do
  before_filter :only => :index do
    @per_page = 100
  end

  scope :active
  scope :inactive
  scope :dead_user
  scope :all

  filter :id
  filter :book_id, :as => :numeric
  filter :user_id, :as => :numeric
  filter :price
  filter :cityid
  filter :can_deliver
  filter :can_postmail


  index do
    selectable_column

    column :id
    column :user_id, :sortable => :user_id do |lot|
      link_to lot.user_id, odminko_user_path(lot.user_id)
    end

    column :book, :sortable => :book_id do |lot|
      link_to lot.book.title, book_path(lot.book_id)
    end

    column :cover do |lot|
      link_to(image_tag(lot.get_cover(:x120), :size => '48x48'), lot_path(lot))
    end

    column :price
    column :comment
    column :delivery do |lot|
      "#{lot.can_deliver? ? 'deliver' : ''}:#{lot.can_postmail? ? 'post' : ''}"
    end
    column :cityid

    column :updated_at

    default_actions
  end
end
