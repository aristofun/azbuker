# coding: utf-8
require 'spec_helper'

describe User do
  before(:each) do
    @usr1 = FactoryGirl.create(:user, :cityid => -1)
    @usr1.reload
  end

  it "should not allow Admin mass asignment" do
    @usr1.should_not be_admin
    us = User.create(FactoryGirl.attributes_for(:user, :admin => true))
    us.should be_valid
    us.should_not be_admin

    FactoryGirl.create(:user, :admin=>true).should be_admin
    FactoryGirl.create(:user, :admin=>false).should_not be_admin
  end


  describe "validations" do

    it "should not save w/o agreement" do
      lambda do
        User.create(FactoryGirl.attributes_for(:user, :agreement => "0")).should_not be_valid
        User.create(FactoryGirl.attributes_for(:user, :agreement => "")).should_not be_valid
        User.create(FactoryGirl.attributes_for(:user, :agreement => nil)).should_not be_valid
        User.create(FactoryGirl.attributes_for(:user, :agreement => "1")).should be_valid
      end.should change(User, :count).by(1)
    end

    it "should validate Skype name" do
      @usr1.should be_valid
      @usr1.skypename = "123"
      @usr1.should_not be_valid

      lambda do
        User.create(FactoryGirl.attributes_for(:user, :skypename => "foo"))
      end.should_not change(User, :count)

      lambda do
        FactoryGirl.create(:user, :skypename => "fooo")
      end.should change(User, :count).by(1)

      FactoryGirl.build(:user, :skypename => "Я"*7).should_not be_valid
      FactoryGirl.build(:user, :skypename => "r"*31).should_not be_valid
      FactoryGirl.build(:user, :skypename => "b"*3).should_not be_valid
      FactoryGirl.create(:user, :skypename => "q"*7).should be_valid
    end

    it "should generate nickname on nil" do
      usr = nil
      lambda do
        usr = FactoryGirl.create(:user, :nickname => '', :email => 'megauser@azbuker.ru')
      end.should change(User, :count).by(1)

      usr.nickname.should == 'megauser'
    end

    it "should not allow nil nickname on update" do
      @usr1.nickname.should_not be_blank
      @usr1.nickname = ''
      @usr1.should_not be_valid
      @usr1.save.should be_false
    end

    it "should validate unique nickname" do
      nik1 = @usr1.nickname
      FactoryGirl.build(:user, :nickname => nik1).should_not be_valid
      FactoryGirl.create(:user, :nickname => nil).should be_valid
      FactoryGirl.create(:user, :nickname => "Я"*20).should be_valid
      FactoryGirl.build(:user, :nickname => "Я"*21).should_not be_valid
      FactoryGirl.build(:user, :nickname => "Я"*2).should_not be_valid
      FactoryGirl.create(:user, :nickname => "Я"*3).should be_valid
    end

    it "should validate unique email" do
      mail1 = @usr1.email
      FactoryGirl.build(:user, :email => mail1).should_not be_valid
      FactoryGirl.build(:user, :email => "sffsf@shit").should_not be_valid
      FactoryGirl.create(:user, :email => "chek@gggg.sdgg.gcsdkd.rug.sm.ru").should be_valid
    end

    it "should set -1 city on nil" do
      @usr1.cityid.should == -1
      FactoryGirl.create(:user, :cityid => 12).cityid.should == 12
      FactoryGirl.create(:user, :cityid => 12).should_not be_admin
    end
  end
end
