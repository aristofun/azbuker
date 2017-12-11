class RegistrationsController < Devise::RegistrationsController

  def show
    @user = User.find(params[:id])

    @lots = Lot.custom(
        :userid => @user.id,
        :is_active => params[:is_active],
        :genre => params[:genre],
        :order_by => params[:order_by],
        :order_to => params[:order_to],
        :page => params[:page],
        :limit => 14
    )
  end

  def after_update_path_for(resource)
    show_user_path(resource)
  end


  # PUT /resource
  # We need to use a copy of the resource because we don't want to change
  # the current user in place.
  def update
    if params[:user][:password].present? || params[:user][:current_password].present?
      super
    else
      @user = User.find(current_user.id)
      if @user.update_without_password(params[:user])
        redirect_to after_update_path_for(@user), :notice => I18n.t("devise.registrations.updated")
      else
        render "edit"
      end
    end
  end
end