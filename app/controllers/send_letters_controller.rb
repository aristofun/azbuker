# coding: utf-8
class SendLettersController < ApplicationController
  before_filter :captcha_and_buildmsg

  # POST /message
  # send to user, set reply-to address
  def message
    process_mess
  end

  # POST /abuse
  # send 2 separate letters to abuse@azbuker and to user
  def abuse
    process_mess
  end

  private
  def captcha_and_buildmsg
    @user_message = UserMessage.new(params[:user_message])
    @captcha_error = !verify_recaptcha unless Rails.env.test?
  end

  def process_mess
    respond_to do |type|
      type.html {
        if !@user_message.valid? || @captcha_error
          flash[:user_message] = @user_message
          flash[:captcha_error] = @captcha_error
          redirect_to lot_path(@user_message.lotid),
                      {:alert => t("generic_errors.sendmsg_form_failed")}
        else
          status = {}
          if deliver(@user_message)
            status = {:notice => t("messages.message_sent")}
          else
            status = {:alert => t("generic_errors.sendmsg_form_failed")}
          end
          redirect_to lot_path(@user_message.lotid), status
        end
      }

      type.js {
        if @user_message.valid? && !@captcha_error
          @status_ok = deliver(@user_message)
          render 'success'
        end
      }
    end
  end

  private
  def deliver(msg)
    begin
      UserMailer.message_or_abuse(msg).deliver
      true
    rescue Exception => e # Net::SMTP errors or sendmail pipe errors
                          #puts e.inspect
      false
    end
  end
end
