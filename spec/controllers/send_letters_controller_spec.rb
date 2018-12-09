# coding: utf-8
require 'spec_helper'
RSpec.describe SendLettersController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:book) { FactoryBot.create(:book) }
  let(:lot) { FactoryBot.create(:lot, book: book) }
  let(:mail_count) { ActionMailer::Base.deliveries.count }
  let(:not_existed_user_id) { '99' }

  before :each do
    @user_messaga = {
      email: 'mymail@azbuker.ru',
      text: 'Fuuck yo uuuu!',
      type: '7',
      lotid: lot.id.to_s,
      userid: user.id.to_s
      }
    mail_count
  end

  it "should set correct status on error" do
      post :message, {user_message: @user_messaga.merge(userid: not_existed_user_id),
                      format: :js}
      expect(assigns(:status_ok)).to be_falsey # no user 99
      expect(response).to render_template('success')

      post :abuse, { user_message: @user_messaga.merge(userid: not_existed_user_id), format: :js }
      expect(assigns(:status_ok)).to be_falsey # no user 99
      expect(response).to render_template('success')

      post :message, { user_message: @user_messaga.merge(userid: not_existed_user_id) }
      expect(response).to_not render_template('success')
      expect(response).to redirect_to(lot_path(lot))
      expect(flash[:alert]).to eq I18n.t("generic_errors.sendmsg_form_failed")
      expect(ActionMailer::Base.deliveries.count).to eq mail_count
  end

  it "should send correct message" do
      @user_messaga.delete(:type)
      post :message, { user_message: @user_messaga, format: :js }
      expect(assigns(:status_ok)).to be_truthy
      expect(response).to render_template('success')

      mail = ActionMailer::Base.deliveries.last

      expect(mail.to).to match_array [user.email]
      expect(mail.subject).to eq I18n.t("mailer.msg_subject", lotid: @user_messaga[:lotid])
      mail.reply_to = @user_messaga[:email]
      expect(mail.body).to match_selector_content("p", 'Вашей книгой интересуется человек с обратным адресом')
      expect(ActionMailer::Base.deliveries.count).to eq mail_count + 1
  end

  it "should send correct abuse" do
    post :message, { user_message: @user_messaga }
    expect(response).to redirect_to(lot_path(lot))
    expect(flash[:notice]).to eq I18n.t("messages.message_sent")

    mail = ActionMailer::Base.deliveries.last

    expect(mail.to).to match_array [Azbuker::Application.config.abusemail]

    expect(mail.subject).to eq I18n.t("mailer.abuse_subject",
                                  lotid: @user_messaga[:lotid],
                                  userid: @user_messaga[:userid])

    mail.reply_to = @user_messaga[:email]
    expect(mail.body).to match_selector_content("p", 'Поступила жалоба на пользователя')
    expect(ActionMailer::Base.deliveries.count).to eq mail_count + 1
  end
end
