class SessionsController < ApplicationController

  skip_filter :require_login

  def index
    redirect_to :action => 'new'
  end

  def new
  end

  def create
    @session = UserSession.create params
    if session
      redirect_to root_url, :notice => "Logged in!"
    else
      flash[:error] = "Invalid email or password"
      render "new"
    end
  end

  def destroy
    UserSession.find.destroy
    redirect_to root_url, :notice => "Logged out!"
  end

end
