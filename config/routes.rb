Azbuker::Application.routes.draw do

  resources :lots, :constraints => {:id => /[0-9]+/} do
    put 'close', :on => :member
  end

  devise_scope :user do
    get "/rega" => 'devise/registrations#rega'
    get "user/:id", :to => "registrations#show", :as => :show_user
  end

  devise_for :users, :controllers => {:registrations => 'registrations'}

  root :to => 'lots#index' #
  get "author/:authorid" => "lots#index_author", :as => :author, :constraints => {:authorid => /[0-9]+/}
  get "book/:bookid" => "lots#index_book", :as => :book, :constraints => {:bookid => /[0-9]+/}
  get "genre/:genreid" => "lots#index_genre", :as => :genre, :constraints => {:genreid =>
                                                                                  /\-?[0-9]+/}

  post 'suggest' => 'books#suggest', :as => :suggest
  get 'search' => 'books#search', :as => :search

  # actions for sending messages from Lot page
  post 'message' => 'send_letters#message', :as => :send_msg
  post 'abuse' => 'send_letters#abuse', :as => :abuse

  get "404.html", :to => "stpages#error_404"
  get "500.html", :to => "stpages#error_500"
  get "page/:action", :to => "stpages", :as => :pages

  ActiveAdmin.routes(self)

  # 404 error
  #get '*not_found' => "stpages#error_404"


  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  #match ':controller(/:action(/:id(.:format)))'
end
