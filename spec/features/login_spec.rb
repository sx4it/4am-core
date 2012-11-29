require 'spec_helper'

describe "the login process", :type => :feature do
  before :each do
    without_access_control do
      @user = create :user
    end
  end

  it "redirect me to login" do
    visit user_path(1)
    current_path.should eq(login_path)
  end

  it "signs me in" do
    visit login_path
    fill_in 'login', :with => @user.login
    fill_in 'password', :with => @user.password
    click_on 'Login'
    current_path.should eq(root_path)
    page.should have_content("Logged in!")
  end

  it "log me out" do
    visit login_path
    fill_in 'login', :with => @user.login
    fill_in 'password', :with => @user.password
    click_on 'Login'
    current_path.should eq(root_path)
    page.should have_content("Logged in!")

    # after login, we log out
    click_on 'Logout'
    current_path.should eq(login_path)
  end
end

describe "the signup process", :type => :feature do
  it "should create an user" do
    visit login_path
    click_on 'New Account'
    current_path.should eq(new_new_user_path)

    fill_in 'user_login', :with => 'user1'
    fill_in 'user_email', :with => 'user1@test.com'
    fill_in 'user_password', :with => 'admin'
    fill_in 'user_password_confirmation', :with => 'admin'

    click_on 'Save'
    current_path.should eq(root_path)
  end

  it "password not matching" do
    visit login_path
    click_on 'New Account'
    current_path.should eq(new_new_user_path)

    fill_in 'user_login', :with => 'user1'
    fill_in 'user_email', :with => 'user1@test.com'
    fill_in 'user_password', :with => 'admin'
    fill_in 'user_password_confirmation', :with => 'admin1'

    click_on 'Save'
    current_path.should eq(new_user_index_path)
  end

  it "invalid email" do
    visit login_path
    click_on 'New Account'
    current_path.should eq(new_new_user_path)

    fill_in 'user_login', :with => 'user1'
    fill_in 'user_email', :with => 'user'
    fill_in 'user_password', :with => 'admin'
    fill_in 'user_password_confirmation', :with => 'admin1'

    click_on 'Save'
    current_path.should eq(new_user_index_path)
  end
end
