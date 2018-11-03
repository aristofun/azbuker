# coding: utf-8
require 'spec_helper'

describe SendLettersController do

  before :each do
    @user = FactoryBot.create(:user)
    book = FactoryBot.create(:book)
    @lot = FactoryBot.create(:lot, :book => book)
    @user_messaga = {
        :email => 'mymail@azbuker.ru',
        :text => 'Fuuck yo uuuu!',
        :type => '7',
        :lotid => @lot.id.to_s,
        :userid => @user.id.to_s
    }
  end

  it "should set correct status on error" do
    expect {
      post :message, {:user_message => @user_messaga.merge(:userid => '99'),
                      :format => 'js'}
      assigns(:status_ok).should be_false # no user 99
      response.should render_template('success')

      post :abuse, {:user_message => @user_messaga.merge(:userid => '99'), :format => 'js'}
      assigns(:status_ok).should be_false # no user 99
      response.should render_template('success')

      post :message, {:user_message => @user_messaga.merge(:userid => '99')}
      response.should_not render_template('success')
      response.should redirect_to(lot_path(@lot))
      flash[:alert].should == I18n.t("generic_errors.sendmsg_form_failed")
    }.to change(ActionMailer::Base.deliveries, :count).by(0)
  end

  it "should send correct message" do
    expect {
      @user_messaga.delete(:type)
      post :message, {:user_message => @user_messaga, :format => 'js'}
      assigns(:status_ok).should be_truthy
      response.should render_template('success')

      mail = ActionMailer::Base.deliveries.last

      mail.to.should == [@user.email]
      mail.subject.should == I18n.t("mailer.msg_subject", :lotid => @user_messaga[:lotid])
      mail.reply_to = @user_messaga[:email]
      mail.body.should match_selector_content("p", 'Вашей книгой интересуется человек с обратным адресом')
    }.to change(ActionMailer::Base.deliveries, :count).by(1)
  end

  it "should send correct abuse" do
    expect {
      post :message, {:user_message => @user_messaga}
      response.should redirect_to(lot_path(@lot))
      flash[:notice].should == I18n.t("messages.message_sent")

      mail = ActionMailer::Base.deliveries.last

      mail.to.should == [Azbuker::Application.config.abusemail]

      mail.subject.should == I18n.t("mailer.abuse_subject",
                                    :lotid => @user_messaga[:lotid],
                                    :userid => @user_messaga[:userid])

      mail.reply_to = @user_messaga[:email]
      mail.body.should match_selector_content("p", 'Поступила жалоба на пользователя')
    }.to change(ActionMailer::Base.deliveries, :count).by(1)
  end
end
