# coding: utf-8

require 'spec_helper'


describe "Users" do
  describe "GET common rega page" do
    it "should exist" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      visit rega_path

      page.should match_selector_content('h4', 'Регистрация')
      page.should match_selector_content("h4", 'Вход')
    end
  end

  describe "adminka" do
    it "should decline anon users" do
      visit odminko_dashboard_path
      page.current_path.should == new_user_session_path
      page.should have_selector("div.alert-message.error")
    end

    it "should allow admin users" do
      user = FactoryBot.create(:user, :admin => true)
      login(user).should be_true
      config1

      visit odminko_dashboard_path
      page.current_path.should == odminko_dashboard_path
      page.should have_no_selector("div.alert-message.error")

      visit odminko_books_path
      page.current_path.should == odminko_books_path
      page.should have_no_selector("div.alert-message.error")

      visit odminko_users_path
      visit odminko_lots_path
      visit odminko_authors_path
      visit odminko_oz_books_path
    end

    it "should decline non-admin users" do
      user = FactoryBot.create(:user)
      login(user).should be_true

      visit odminko_dashboard_path
      #puts user.inspect
      #puts page.body
      page.current_path.should == root_path
      page.should have_selector("div.alert-message.error")

      visit new_odminko_author_path
      page.current_path.should == root_path
      page.should have_selector("div.alert-message.error")
    end

  end

  describe "GET 'edit'" do

    before(:each) do
      @user = FactoryBot.create(:user)
      login(@user).should be_true
    end

    it "should n't allow anonym user" do
      logout(@user).should be_true
      visit edit_user_registration_path
      page.current_path.should == new_user_session_path
      page.should have_selector("div.alert-message.error")
    end


    it "should save Nickname/skype/phone without pass" do
      old_phone = "925-35-35-700"
      old_nick = "hfkjhwehr боря< vh"
      old_skype = "skype_gAt.rr"
      old_city = @user.cityid

      usr = FactoryBot.create(:user, :phone => old_phone, :nickname => old_nick,
                               :skypename => old_skype, :cityid => old_city)

      logout(@user)
      login(usr)

      visit edit_user_registration_path

      page.current_path.should == edit_user_registration_path
      page.should match_selector_content("div.sellerinfo p small", usr.email)

      new_phone = "+8925)35-35--700"
      new_nick = "nik Василий Ку"
      new_skype = "skype_my_gAt.rr"
      new_cityid = 7

      update_reg(new_nick, new_phone, new_skype, new_cityid, '') #, @user.password)

      page.current_path.should == show_user_path(usr)
      page.should match_selector_content("div.sellerinfo h5", new_nick.html_safe)
      page.should match_selector_content("div.sellerinfo address strong", new_phone)
      page.should match_selector_content("div.sellerinfo p strong", Globals::CITIES[new_cityid])
      page.should match_selector_content("div.sellerinfo address strong a", new_skype)
      page.should have_no_selector("div.clearfix.error")
    end

    it "should change User password" do
      new_pass = "skype_my_rr"

      visit edit_user_registration_path

      update_reg(@user.nickname, '', '', 0, @user.password, new_pass)

      page.current_path.should == show_user_path(@user)
      page.should match_selector_content("div.alert-message", I18n.t("devise.registrations.updated"))


      logout(@user).should be_true
      login(@user).should be_false
      @user.password = new_pass
      login(@user).should be_true
    end

    it "should save Nickname/skype/phone with pass" do
      visit edit_user_registration_path

      page.current_path.should == edit_user_registration_path
      page.should match_selector_content("div.sellerinfo p small", @user.email)

      new_phone = "925-35-35-700"
      new_nick = "hfkjhweh                <p>                vh"
      new_skype = "skype_my_gAt.rr"
      new_cityid = 11

      update_reg(new_nick, new_phone, new_skype, new_cityid, @user.password)

      page.current_path.should == show_user_path(@user)
      page.should match_selector_content("div.sellerinfo h5", new_nick.squish)
      page.should match_selector_content("div.sellerinfo address strong", new_phone)
      page.should match_selector_content("div.sellerinfo p strong", Globals::CITIES[new_cityid])
      page.should match_selector_content("div.sellerinfo address strong a", new_skype)
      page.should match_selector_content("div.alert-message", I18n.t("devise.registrations.updated"))
    end

    def update_reg(new_nick, new_phone, new_skype, new_cityid, curr_pw, new_pw = '')
      #p page.body
      within(:xpath, "//form[@id='edit_user']") do
        fill_in 'user_nickname', :with => new_nick
        fill_in 'user_phone', :with => new_phone
        fill_in 'user_skypename', :with => new_skype
        select Globals::CITIES[new_cityid], :from => 'user_cityid'

        fill_in 'user_current_password', :with => curr_pw
        fill_in 'user_password', :with => new_pw
        click_button "Сохранить"
      end
    end

    after(:each) do
      logout @user
    end

    after(:all) do
      User.delete_all
    end
  end


  describe "sing_in" do
    it "should not sign UNCONFIRMED user & show resend link" do
      user = FactoryBot.create(:user)
      user.confirmed_at = nil
      user.save
      login(user, user_session_path, false).should be_false

      page.current_path.should == user_session_path
      page.should match_selector_content("div.alert-message", I18n.t("devise.failure.unconfirmed"))
      page.should have_xpath("//a[@href='#{new_user_confirmation_path(:email => user.email)}']")
    end

    it "should not sign a user in" do
      lambda do
        visit rega_path

        within(:xpath, "//form[@action='#{user_session_path}']") do
          fill_in 'user_email', :with => "@@@"
          fill_in 'user_password', :with => "123"
          uncheck 'user_remember_me'
          click_button "Войти"
        end

        page.current_path.should == user_session_path
        page.should match_selector_content("div.alert-message", I18n.t("devise.failure.invalid"))
      end.should_not change(User, :count)
    end

  end

  describe "signup" do

    it "should NOT make new user" do
      lambda do
        visit rega_path

        within(:xpath, "//form[@action='#{user_registration_path}']") do
          fill_in 'user_email', :with => "sfsd@m"
          fill_in 'user_password', :with => ""
          check 'user_agreement'
          click_button "Готово"
        end

        page.current_path.should == user_registration_path
        page.should have_selector("div.clearfix.error", :count => 2)
      end.should_not change(User, :count)
    end
  end
end
