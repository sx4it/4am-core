module Login
  def login(who)
    activate_authlogic
    without_access_control do
      @user = create who.to_sym
    end
    UserSession.create(@user)
    @user
  end
end
