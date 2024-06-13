class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :current_year
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :surname, :username, :mobile, :avatar, :email, :password, :password_confirmation])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :surname, :username, :mobile, :avatar, :colour, :email, :role, :password, :password_confirmation])
  end

  def current_year
    date = Time.zone.now.to_date
    month = date.month
    year = date.strftime('%y').to_i
    @current_year = month < 9 ? "#{year-1}/#{year}" : "#{year}/#{year+1}"
    @last_year = month < 9 ? "#{year-2}/#{year-1}" : "#{year-1}/#{year}"
    @next_year = month < 9 ? "#{year+1}/#{year}" : "#{year+1}/#{year+2}"
  end

  helper_method :admin?
  def admin?
    current_user && current_user.admin == true
  end

  helper_method :agent?
  def agent?
    current_user && current_user.role == "Agent"
  end

  helper_method :finance?
  def finance?
    current_user && current_user.role == "Finance"
  end
end
