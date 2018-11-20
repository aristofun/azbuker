require 'spec_helper'
RSpec.describe RegistrationsController, type: :controller do

  before(:each) do
    @user = FactoryBot.create(:user)

    10.times do
      FactoryBot.create(:lot, :book => FactoryBot.create(:book_w_author), :user => @user)
    end
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe "SHOW action" do

    it "should show user with his lots" do
      get :show, {:id => @user.id}
      usr = assigns(:user)
      usr.should == @user
      #
      lots = assigns(:lots)
      #puts lots.length
      lots.should == @user.lots.sort_by(&:updated_at).reverse[0..13]
      response.should render_template("registrations/show")
    end
  end

end
