class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :require_login

  def require_login
    redirect_to :login unless current_user
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  before_filter { |c| Authorization.current_user = c.current_user }

  protected

  def permission_denied
    flash[:error] = "Sorry, you are not allowed to access that page."
    redirect_to root_url
  end

  helper_method :current_user
end
