class SessionsController < ApplicationController

  skip_filter :require_login

  def index
    redirect_to :action => 'new'
  end

  def new
  end

  def create
    user = User.find_by_login(params[:login])
    if user && user.authenticate(params[:pass])
      puts "OK"
      session[:user_id] = user.id
      redirect_to root_url, :notice => "Logged in!"
    else
      puts "KO"
      flash[:error] = "Invalid email or password"
      render "new"
      #redirect_to :action => 'new', :alert => "WAZAAAA"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Logged out!"
  end

end
