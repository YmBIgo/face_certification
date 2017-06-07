class UsersController < ApplicationController

  before_action :authenticate_user!
  before_action :authenticate_valid_user
  before_action :set_user, :only => [:show, :edit, :update, :authenticate]
  before_action :check_valid_user, :only => [:edit, :update, :authenticate]
  before_action :check_full_name, :only => [:show]

  def show
    if @user.id == current_user.id
      unless @user.azure_id.present?
        @azure_response = azure_create_person
        current_user.update(:azure_id => azure_json(@azure_response, "personId") )
      end
    end
    # logger.error "\nhoge\n"
    @u_photos = UPhoto.where(:user_id => @user.id)
  end

  def index
    @users = User.all
  end

  def edit
  end

  def update
    if Rails.env.development?
      @user.update(user_params)
      flash[:notice] = "editing completed!"
    else
      flash[:alert] = "it is unpermitted to update user in production environment."
    end
    redirect_to edit_user_path(@user.id)
  end

  def authenticate
    if current_user.user_authenticate_user_or_not == true
      current_user.update(:user_authenticate_user_or_not => false, :valid_user_or_not => false)
      flash[:alert] = "unset user face authentication."
      redirect_to user_path(current_user.id)
    else
      current_user.update(:user_authenticate_user_or_not => true)
      flash[:alert] = "set user face authentication."
      redirect_to user_path(current_user.id)
    end
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:family_name, :first_name, :top_image)
  end

  def check_full_name
    unless current_user.full_name?
      redirect_to edit_user_path(current_user.id)
    end
  end

  def check_valid_user
    unless @user.id == current_user.id
      flash[:alert] = "invalid user"
      redirect_to user_path(current_user.id)
    end
  end

end
