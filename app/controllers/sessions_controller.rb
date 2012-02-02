class SessionsController < ApplicationController

  skip_filter :require_login

  def new
  end

  def create
    user = User.find_by_login(params[:login])
    if user && user.authenticate(params[:pass])
      session[:user_id] = user.id
      redirect_to root_url, :notice => "Logged in!"
    else
      flash.now.alert = "Invalid email or password"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Logged out!"
  end

end
