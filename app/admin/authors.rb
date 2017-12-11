ActiveAdmin.register Author do

  before_filter :only => :index do
    @per_page = 50
  end


  scope :all
  scope :unbooked

  filter :id
  filter :first
  filter :last

  #batch_action :destroy
  #batch_action :flag do |selection|
  #  Author.find(selection).each { |p| puts p.id }
  #  redirect_to collection_path, :notice => "Posts flagged!"
  #end

  index do
    selectable_column
    column :id
    column :first
    column :middle
    column :last do |author|
      link_to author.last, author_path(author)
    end
    column :full
    column :short
    column :books do |author|
      author.books.count
    end
    default_actions
  end

end
