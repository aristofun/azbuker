class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_500
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from ActionController::UnknownAction, with: :render_404
    rescue_from AbstractController::ActionNotFound, with: :render_404
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
  end

  rescue_from CanCan::AccessDenied, :with => :set_redir_after_login

  def set_redir_after_login(exc)
    #puts "\nCanCan::AcDen"
    if current_user
      redirect_to show_user_path(current_user), :alert => t("generic_errors.cancan")
    else
      session[:user_return_to] = request.fullpath
      redirect_to new_user_session_path, :alert => t("devise.failure.unauthenticated")
    end
  end

  def authenticate_admin_user!
    if current_user.blank?
      redirect_to(new_user_session_path, :alert => t("devise.failure.unauthenticated"))
    elsif !current_user.admin?
      redirect_to(root_path, :alert => "get out!")
    end
  end


  # Customize the Devise after_sign_in_path_for() for redirecct to previous page after login
  #  def after_sign_in_path_for(resource_or_scope)
  #07	    case resource_or_scope
  #08	    when :user, User
  #	      store_location = session[:return_to]
  #	      clear_stored_location
  #(store_location.nil?) ? "/" : store_location.to_s
  #12	    else
  #13	      super
  #14	    end
  #	  end

  private

  def render_404(exception)
    params[:not_found] = exception.message
    render template: 'stpages/error_404', status: 404
  end

  def render_500(exception)
    # s = "rescued_from:: #{params[:controller]}##{params[:action]}: #{exception.inspect}\n#{exception.backtrace.to_s}\n"
    # logger.error s
    render template: 'stpages/error_500', status: 500
  end

  def get_city
    set_default_city
    cookies[:cityid]
  end

  def set_default_city
    if params.has_key?('cityid')
      if params[:cityid].blank? # filter sets city to any
        cookies.permanent[:cityid] = nil
      else
        cookies.permanent[:cityid] = params[:cityid]
        session[:cityid] = params[:cityid] # xxx: cache_action can't access cookies
      end
    else
      if current_user
        (cookies.permanent[:cityid] = current_user.cityid) if cookies[:cityid].blank?
        (session[:cityid] = current_user.cityid) if cookies[:cityid].blank?
      end
    end
  end

  def clear_backredirect
    # avoid permanent redirecting to this
    session[:user_return_to] = nil
  end

  def base_error_add(error)
    session[:base_errors] ||= []
    session[:base_errors] << error if error.present?
  end

  def after_sign_out_path_for(resource)
    #puts "REDIRback" + request.referrer
    begin
      Rails.application.routes.recognize_path(request.referrer, :method => :get)

      if request.referrer != new_lot_url
        return request.referrer || root_path
      else
        return root_path
      end
    rescue
      root_path
    end
  end

  def populate_virtual_attributes(lot, book = lot.book)
    if book
      lot.book_title = book.title
      lot.book_authors = book.authorstring
      lot.book_genre = book.genre
      lot.bookid = book.id if book.id.present?
    end
  end

  def strip_like_symbols(str)
    str.gsub('%', '\%').gsub('_', '\_') + '%'
  end
end