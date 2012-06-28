class SessionsController < ApplicationController

  skip_filter :require_login

  def index
    redirect_to :action => 'new'
  end

  def new
    unless request.env['X-SSL_CLIENT_CERT'].nil? or request.env['X-SSL_CLIENT_CERT'].size == 0
      @user = User.find_by_x509(request.env['X-SSL_CLIENT_CERT'])
    end
  end

  def create
    if not request.env['X-SSL_CLIENT_CERT'].nil? and not request.env['X-SSL_CLIENT_CERT'].size == 0
      @user = User.find_by_x509(request.env['X-SSL_CLIENT_CERT'])
      @session = UserSession.create @user unless @user.nil?
    else
      @session = UserSession.create params
    end
    if session
      redirect_to root_url, :notice => "Logged in!"
    else
      flash[:error] = "Invalid login informations."
      render "new"
    end
  end

  def destroy
    UserSession.find.destroy
    redirect_to root_url, :notice => "Logged out!"
  end

end
