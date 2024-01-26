class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(name: params[:login][:name].downcase)
    if user && user.authenticate(params[:login][:password])
      session[:user_id] = user.id.to_s
      redirect_to root_path
    elsif user
      @errors = "Wrong password"
      render :new, status: :unprocessable_entity
    else
      @errors = "User with name not found"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
