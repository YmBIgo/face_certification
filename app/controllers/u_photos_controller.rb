class UPhotosController < ApplicationController

  before_action :authenticate_user!
  before_action :authenticate_valid_user
  before_action :set_u_photo, :only => [:learn, :unlearn, :destroy]
  before_action :check_valid_user_from_uphoto, :only => [:learn, :unlearn]

  def new
    set_s3_direct_post
    @u_photo = UPhoto.new
  end

  def create
    @u_photo = UPhoto.create(uphoto_params.merge(:user_id => current_user.id))
    azure_face_url = "https:" + @u_photo.aws_url
    azure_response = azure_set_face_image_to_user(@u_photo.user.azure_id, azure_face_url)
    azure_face_id = azure_json(azure_response, "persistedFaceId")
    @u_photo.update(:azure_id => azure_face_id)
    flash[:notice] = "registeration complete!"
    redirect_to user_path(@u_photo.user_id)
  end

  def index
    @u_photos = UPhoto.where(:user_id => current_user.id)
  end

  def destroy
  end

  def learn
    unless @u_photo.azure_id.present?
      azure_face_url = "https:" + @u_photo.aws_url
      azure_response = azure_set_face_image_to_user(@u_photo.user.azure_id, azure_face_url)
      azure_face_id = azure_json(azure_response, "persistedFaceId")
      @u_photo.update(:azure_id => azure_face_id)
      flash[:notice] = "registeration complete!"
    else
      flash[:alert] = "you have registered photo."
    end
    azure_train_user_face
    redirect_to user_path(current_user.id)
  end

  def unlearn
    if @u_photo.azure_id.present?
      azure_face_url = @u_photo.azure_id
      @azure_response = azure_delete_user_face_image(@u_photo.user.azure_id, azure_face_url)
      @u_photo.update(:azure_id => "")
      flash[:notice] = "registeration complete!"
    else
      flash[:alert] = "you have registered photo."
    end
    azure_train_user_face
    redirect_to user_path(current_user.id)
  end

  private
  def uphoto_params
    params.require(:u_photo).permit(:user_id, :azure_id, :aws_url)
  end

  def set_u_photo
    @u_photo = UPhoto.find(params[:id])
  end

  def check_valid_user_from_uphoto
    unless @u_photo.user.id == current_user.id
      flash[:alert] = "invalid user"
      redirect_to user_path(current_user.id)
    end
  end

end
