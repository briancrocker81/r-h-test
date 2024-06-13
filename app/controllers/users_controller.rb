class UsersController < ApplicationController
  include Pagy::Backend

  def index
    @filterrific = initialize_filterrific(
      User,
      params[:filterrific],
      select_options: {
        sorted_by: User.options_for_sorted_by
      },
      persistence_id: "user_key",
      default_filter_params: {},
      sanitize_params: true,
      ) || return
    @pagy, @users = pagy(@filterrific.find, items: 20)

    respond_to do |format|
      format.html
      format.js
    end

    rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{e.message}"
    redirect_to(reset_filterrific_url(format: :html)) && return
  end

  def new
    @user = User.new
  end

  def create
    password = temp_password
    @user = User.new(user_params.merge!(password: password))
    if @user.save
      UserMailer.temp_password(@user.id, password).deliver_now
      flash[:notice] = "Successfully created user!"
    else
      flash[:alert] = @user.errors.full_messages.join(', ')
    end
    redirect_to users_path()
  end

  def show
    @user = User.find params[:id]
  end

  def edit
    @colors = User.all.map{|u| [u.colour, u.full_name]}.to_h
    @user = User.find params[:id]
  end

  def update
    @colors = User.all.map{|u| [u.colour, u.full_name]}.to_h
    @user = User.find params[:id]
    if @user.present?
      if @user.update(user_params)
        flash[:notice] = "Successfully updated user!"
      else
        flash[:alert] = @user.errors.full_messages.join(', ')
      end
    else
      flash[:alert] = "No user found!"
    end
    redirect_to users_path()
  end

  def destroy
    @user = User.find params[:id]
    if @user.present?
      if @user.destroy
        flash[:notice] = "Successfully deleted user!"
      else
        flash[:alert] = "Something went wrong, Please try again later!"
      end
    else
      flash[:alert] = "No user found!"
    end
    redirect_to users_path()
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :surname, :mobile, :avatar, :email, :username, :admin, :role)
  end

  def temp_password
    temp_password = SecureRandom.urlsafe_base64(nil, false)
    @temp_password = temp_password
  end
end
