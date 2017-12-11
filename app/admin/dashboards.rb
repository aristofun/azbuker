ActiveAdmin::Dashboards.build do

  # Define your dashboard sections here. Each block will be
  # rendered on the dashboard in the context of the view. So just
  # return the content which you would like to display.

  section "Recent Users" do
    table_for User.order("updated_at desc").limit(50) do
      column :email do |user|
        link_to user.email, odminko_user_path(user)
      end
      column :nickname
      column :id do |user|
        link_to user.id, show_user_path(user)
      end
    end
    strong { link_to "All Users", odminko_users_path }
  end

  section "Recent Lots" do
    table_for Lot.order("updated_at desc").limit(25) do
      column :id do |lot|
        link_to lot.id, odminko_lot_path(lot)
      end
      column :book_id do |lot|
        link_to lot.book_id, book_path(lot.book_id)
      end
      column :price
      column :cityid
      column :user_id do |lot|
        link_to lot.user_id, show_user_path(lot.user_id)
      end

      column :cover do |lot|
        link_to(image_tag(lot.get_cover(:x120), :size => '40x40'), lot_path(lot))
      end
    end
    strong { link_to "All Lots", odminko_lots_path }
  end

  section "Recent Books" do
    table_for Book.order("updated_at desc").limit(25) do
      column :id do |book|
        link_to book.id, odminko_book_path(book)
      end
      column :title do |book|
        link_to book.title, book_path(book)
      end
      column :genre
      column :lots_count
      column :cover do |book|
        link_to(image_tag(book.get_cover(:x120), :size => '40x40'), book_path(book))
      end

    end
    strong { link_to "All Books", odminko_books_path }
  end
  # == Simple Dashboard Section
  # Here is an example of a simple dashboard section
  #
  #   section "Recent Posts" do
  #     ul do
  #       Post.recent(5).collect do |post|
  #         li link_to(post.title, admin_post_path(post))
  #       end
  #     end
  #   end

  # == Render Partial Section
  # The block is rendered within the context of the view, so you can
  # easily render a partial rather than build content in ruby.
  #
  #   section "Recent Posts" do
  #     div do
  #       render 'recent_posts' # => this will render /app/views/admin/dashboard/_recent_posts.html.erb
  #     end
  #   end

  # == Section Ordering
  # The dashboard sections are ordered by a given priority from top left to
  # bottom right. The default priority is 10. By giving a section numerically lower
  # priority it will be sorted higher. For example:
  #
  #   section "Recent Posts", :priority => 10
  #   section "Recent User", :priority => 1
  #
  # Will render the "Recent Users" then the "Recent Posts" sections on the dashboard.

  # == Conditionally Display
  # Provide a method name or Proc object to conditionally render a section at run time.
  #
  # section "Membership Summary", :if => :memberships_enabled?
  # section "Membership Summary", :if => Proc.new { current_admin_user.account.memberships.any? }

end
