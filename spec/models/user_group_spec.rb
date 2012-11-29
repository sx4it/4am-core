require 'spec_helper'

describe 'admin can add user in user_group' do

  before :each do
    @user = login(:user)

    @admin = login(:admin)
    Authorization.current_user = @admin
  end

  it "can add role to someone" do
    r = UserGroup.create(:name => "test")
    expect do
      u = @user.user_group = [r]
      @user.save
    end.to_not raise_error
  end
end

describe 'user cannot add user in user_group' do

  before :each do
    @user2 = login(:user)
    @user = login(:user)

    Authorization.current_user = @user2
  end

  it "cannot add role to someone" do
    r = UserGroup.create(:name => "test")
    expect do
      u = @user.user_group = [r]
      @user.save
    end.to raise_error(Authorization::NotAuthorized)
  end
end

describe 'user cannot add himself in user_group' do

  before :each do
    @user = login(:user)

    Authorization.current_user = @user
  end

  it "cannot add role to someone" do
    r = UserGroup.create(:name => "test")
    expect do
      u = @user.user_group = [r]
      @user.save.should raise_error
    end.to raise_error(Authorization::NotAuthorized)
  end
end
