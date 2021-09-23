class AuthenticatedUsersController < ApplicationController
  before_action :authenticate_user!

  def current_user
    @current_user ||= session[:current_user_id] &&
      User.find(session[:current_user_id])
  end

  def user_signed_in?
    !current_user.nil?
  end

  def sign_in(user)
    session[:current_user_id] = user.id
    redirect_current_user_to_homepage
  end

  def redirect_current_user_to_homepage
    if current_user.admin?
      redirect_to admin_users_path
    else
      redirect_to user_path(current_user)
    end
  end

  private

  def authenticate_user!
    unless user_signed_in?
      redirect_to login_path, alert: 'Veuillez vous connecter pour accéder à cette page.'
    end
  end
end
