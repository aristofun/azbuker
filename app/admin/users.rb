ActiveAdmin.register User do
  before_filter :only => :index do
    @per_page = 50
  end

  filter :id
  filter :email
  filter :nickname
  filter :phone
  filter :skypename
  filter :created_at
  filter :sign_in_count
  filter :last_sign_in_at


  scope :all
  scope :unconfirmed
  scope :admins


  index do
    selectable_column

    column :id
    column :email, :sortable => :email do |user|
      link_to user.email, show_user_path(user)
    end
    column :nickname
    column :phone
    column :skypename
    #if can? :manage, User
    column :sign_in_count
    column :lots_num do |user|
      user.lots.count
    end

    default_actions
  end

end
