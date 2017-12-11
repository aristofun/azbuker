# coding: utf-8
class CustomDeviseFailure < Devise::FailureApp

  def redirect_url
    if warden_message == :unconfirmed
      flash[:alert] = I18n.t("devise.failure.unconfirmed") + " <a class='label success' /
href='#{new_user_confirmation_path(:email => params[:user][:email])}'>Выслать заново</a>".html_safe
      super
    else
      super
    end
  end

end