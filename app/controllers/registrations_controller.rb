class RegistrationsController < Devise::RegistrationsController
  before_action :set_user, only: :show
  before_action :set_current_user, only: :update

  def show
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
    if params[:user][:password].blank? && params[:user][:current_password].blank?
      params[:user].delete(:password)
      params[:user].delete(:current_password)

      @user.update!(account_update_params)
      redirect_to after_update_path_for(@user), :notice => I18n.t("devise.registrations.updated")
    elsif params[:user][:password].present? && params[:user][:current_password].present?
      @user.update!(account_update_params)
      sign_in(@user, :bypass => true)
      redirect_to after_update_path_for(@user), :notice => I18n.t("devise.registrations.updated_and_change_password")
    elsif params[:user][:password] != nil
      params[:user].delete(:password)
      params[:user].delete(:current_password)

      @user.update!(account_update_params)
      redirect_to after_update_path_for(@user), :notice => I18n.t("devise.registrations.updated")
    else
      render "edit"
    end
  end

  private

  def set_current_user
    @user = User.find(current_user.id)
  end

  def set_user
    @user = User.find(params[:id])
  end


  def account_update_params
    params.require(:user).permit(:agreement, :email, :password, :password_confirmation,# :current_password,
                                 :remember_me, :nickname, :phone, :skypename, :cityid)
  end
end

