class Users::PasswordsController < Devise::PasswordsController

  def new
    redirect_to root_path, alert: "it is unpermitted to access this page."
  end

  def create
    redirect_to root_path, alert: "it is unpermitted to create password."
  end

  def edit
    redirect_to root_path, alert: "it is unpermitted to edit password."
  end

  def update
    redirect_to root_path, alert: "it is unpermitted to update password."
  end

  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
