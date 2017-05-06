class VPhotosController < ApplicationController

  def new
    set_s3_direct_post
    @v_photo = VPhoto.new
  end

  def create
    @v_photo = VPhoto.create(vphoto_params.merge(:user_id => current_user.id))
    # first of all generate face
    azure_face_url = "https:" + @v_photo.aws_url
    azure_face_id = azure_generate_face(azure_face_url)
    azure_is_identical = azure_varify_face(azure_face_id, current_user.azure_id)
    @v_photo.update(:azure_id => azure_face_id, :identical_or_not => azure_is_identical)
    if azure_is_identical == true
      current_user.update(:valid_user_or_not => true)
      flash[:notice] = "validation success!"
      redirect_to user_path(current_user.id)
    else
      flash[:alert] = "validation failed! try again."
      redirect_to "/v_photos/new"
    end
  end

  private
  def vphoto_params
    params.require(:v_photo).permit(:user_id, :azure_id, :aws_url, :identical_or_not)
  end

end
