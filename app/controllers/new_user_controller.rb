class NewUserController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create]
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])


    respond_to do |format|
      if @user.save
        format.html { redirect_to root_url, notice: 'User was successfully created.' }
        format.json { render json: root_url, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
end
