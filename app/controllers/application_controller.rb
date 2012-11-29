class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user_session, :current_user

  before_filter :require_login

  def require_login
    respond_to do |format|
      format.any(:html, :js) { redirect_to :login unless current_user }
      format.json { render json: {:error => "Please login first."}, :status => 403 unless current_user }
    end
  end

  protected
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
  end

  before_filter { |c| Authorization.current_user = c.current_user }

  protected

  def permission_denied
    flash[:error] = "Sorry, you are not allowed to access that page."

    respond_to do |format|
      format.html { redirect_to root_url }
      format.json { render json: {:error => "You dont have access."} }
    end
  end

  def verified_request?
    if request.content_type == "application/json"
      true
    else
      super()
    end
  end
end
