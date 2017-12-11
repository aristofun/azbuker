class UserMailer < ActionMailer::Base
  ADMINMAIL = Rails.env.development? ? "aristofun@yandex.ru" : "azbuker@azbuker.ru"

  default from: Azbuker::Application.config.backemail

  def welcome_alert(user)
    @user = user
    mail(:to => user.email, :subject => t("mailer.welcome_alert_subject"))
  end

  # can throw exception if given user not found in DB!
  def message_or_abuse(umsg)
    @umsg = umsg
    @user = User.find(@umsg.userid)
    email_opts = {}
    if @umsg.type.present? # abuse
      email_opts[:subject] = t("mailer.abuse_subject", :lotid => @umsg.lotid, :userid => @umsg.userid)
      email_opts[:to] = Azbuker::Application.config.abusemail
      email_opts[:reply_to] = @umsg.email
      #email_opts[:bcc] = @user.email
      email_opts[:template_name] = 'abuse'
    else # mail to user
      email_opts[:subject] = t("mailer.msg_subject", :lotid => umsg.lotid)
      email_opts[:to] = @user.email
      email_opts[:bcc] = ADMINMAIL
      email_opts[:reply_to] = @umsg.email
      email_opts[:template_name] = 'msg'
    end

    mal = mail(email_opts)
    mal.raise_delivery_errors = true
    mal
  end

  def tech_error(subj, body = '')
    mail(:to => ADMINMAIL, :subject => subj, :body => body)
  end
end
