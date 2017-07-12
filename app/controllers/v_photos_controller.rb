require "exif"
require "exifr"

class VPhotosController < ApplicationController

  def new
    set_s3_direct_post
    @v_photo = VPhoto.new
  end

  def create
    image_file = params[:v_photo][:face_image].tempfile
    image_file_content = read_iphone_image(image_file)

    if check_iphone_image(image_file_content)
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
        return
      end
    else
      flash[:alert] = "validation failed! try again."
      redirect_to "/v_photos/new"
    end
  end

  private
  def vphoto_params
    params.require(:v_photo).permit(:user_id, :aws_url)
  end

  def read_iphone_image(file)
    data = Exif::Data.new(file.path)
    model = data.model
    date = data.date_time.to_s
    logger.info("#{model}, #{date}")
    # File.open(file) do |f|
    #   file_content = f.read(500)
    #   logger.error(file_content)
    #   return file_content
    # end
    return [model, date]
  end

  def check_iphone_image(content)
    logger.info(content)
    # useragent iphone
    check_useragent_regexp = /iPhone\s(3|4|5|6|7)/
    # date
    # check_date_regexp = /\d{4}:\d{2}:\d{2}\s\d{2}:\d{2}:\d{2}/
    check_date_regexps = create_date_regexp
    logger.info(check_date_regexps)
    matcher1 = content[0].match(check_useragent_regexp)
    matcher2 = content[1].match(check_date_regexps[0])
    matcher3 = content[1].match(check_date_regexps[1])
    matcher4 = content[1].match(check_date_regexps[2])
    logger.info("#{matcher1}, #{matcher2}, #{matcher3}, #{matcher4}")
    if matcher1 != nil && ( matcher2 != nil || matcher3 != nil || matcher4 != nil )
      return true
    else
      return false
    end
  end

  def create_date_regexp
    t = Time.now
    year = t.year
    month =  t.strftime("%m")
    day = t.strftime("%d")
    b_hour = t.strftime("%H").to_i
    hour_array = [b_hour-1, b_hour, b_hour+1]
    if b_hour == 0
      hour_array = ["23", "00", "01"]
    else
      hour_array = [(b_hour-1).to_s, (b_hour).to_s, (b_hour+1).to_s]
    end
    minite = t.strftime("%M")
    photo_time_regexp_array =
    # [/#{year}:#{month}:#{day}\s#{hour_array[0]}:#{day}/,
    #  /#{year}:#{month}:#{day}\s#{hour_array[1]}:#{day}/,
    #  /#{year}:#{month}:#{day}\s#{hour_array[2]}:#{day}/]
    [/#{year}-#{month}-#{(day.to_i-1).to_s}\s#{hour_array[0]}/,
     /#{year}-#{month}-#{day}\s#{hour_array[1]}/,
     /#{year}-#{month}-#{day}\s#{hour_array[2]}/]
    return photo_time_regexp_array
  end

end
