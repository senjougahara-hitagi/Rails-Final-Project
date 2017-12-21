class SessionsController < ApplicationController
  def new
  end

  def create
    if params[:session].present?
      user = User.find_by email: params[:session][:email].downcase
      if user && user.authenticate(params[:session][:password])
        if user.activated?
          log_in user
          params[:session][:remember_me] == "1" ? remember(user) : forget(user)
          redirect_back_or user
        else
          flash[:warning] = t "warning.activation"
          redirect_to root_url
        end
      else
        flash.now[:danger] = t "danger.email"
        render :new
      end
    else
      user = User.from_omniauth(request.env["omniauth.auth"])
      if user
        user.activate
        log_in user
        flash[:success] = t "success.login"
        redirect_back_or user
      else
        redirect_to root_url
      end
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
