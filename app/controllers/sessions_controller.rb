class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.authenticate(params[:login], params[:pass])

    if user
      session[:user_id] = user.id
      redirect_to root_url, :notice => "Logged."
    else
      flash.now.alert = 'Invalid email or password'
      render "new"
    end

  end

end
