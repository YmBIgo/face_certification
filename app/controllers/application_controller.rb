require "net/http"

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def set_s3_direct_post
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
  end

  def azure_json(json, key)
    azure_hash = JSON.parse(json)
    return azure_hash[key]
  end

  def get_response(uri, request)
    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(request)
    end
    logger.debug(response.body)
    return response.body
  end

  def azure_set_request(request)
    request['Content-Type'] = 'application/json'
    request['Ocp-Apim-Subscription-Key'] = ENV['AZURE_FACE_KEY']
    return request
  end

  def azure_set_face_image_to_user(user, u_photo_url)
    uri = URI("https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/sfc_takedaken_web/persons/#{user}/persistedFaces")
    uri.query = URI.encode_www_form({})
    request = Net::HTTP::Post.new(uri.request_uri)
    request = azure_set_request(request)
    request.body = "{'url':'#{u_photo_url}'}"
    return get_response(uri, request)
  end

  def azure_create_person
    uri = URI("https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/sfc_takedaken_web/persons")
    person_name = current_user.full_name
    uri.query = URI.encode_www_form({})
    request = Net::HTTP::Post.new(uri.request_uri)
    request = azure_set_request(request)
    request.body = "{'name':'#{person_name}'}"
    return get_response(uri, request)
  end

  def azure_delete_user_face_image(user, u_photo_id)
    uri = URI("https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/sfc_takedaken_web/persons/#{user}/persistedFaces/#{u_photo_id}")
    uri.query = URI.encode_www_form({})
    request = Net::HTTP::Delete.new(uri.request_uri)
    request = azure_set_request(request)
    return get_response(uri, request)
  end

  def azure_train_user_face
    uri = URI("https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/sfc_takedaken_web/train")
    # uri = URI("https://westus.api.cognitive.microsoft.com/face/v1.0/persongroups/sfc_takedaken_web/training")
    uri.query = URI.encode_www_form({})
    request = Net::HTTP::Post.new(uri.request_uri)
    # request = Net::HTTP::Get.new(uri.request_uri)
    request = azure_set_request(request)
    return get_response(uri, request)
  end

  def azure_generate_face(photo_url)
    uri = URI("https://westus.api.cognitive.microsoft.com/face/v1.0/detect")
    uri.query = URI.encode_www_form({
      'returnFaceId' => 'true',
      'returnFaceLandmarks' => 'false'
    })
    request = Net::HTTP::Post.new(uri.request_uri)
    request = azure_set_request(request)
    request.body ="{
  'url' : '#{photo_url}'
}"
    azure_face_json = JSON.parse(get_response(uri, request))
    return azure_face_json[0]["faceId"]
  end

  def azure_varify_face(face, user)
    uri = URI("https://westus.api.cognitive.microsoft.com/face/v1.0/verify")
    uri.query = URI.encode_www_form({})

    request = Net::HTTP::Post.new(uri.request_uri)
    request = azure_set_request(request)
    request.body =
"{
  'faceId':'#{face}',
  'personId':'#{user}',
  'personGroupId':'sfc_takedaken_web'
}"
    azure_varify_result = get_response(uri, request)
    # logger.info azure_varify_result
    return azure_json(azure_varify_result, "isIdentical")
  end

  def authenticate_valid_user
    if user_signed_in?
      if current_user.user_authenticate_user_or_not == true
        if current_user.valid_user_or_not == false
          flash[:alert] = "please valid your user information!"
          redirect_to "/v_photos/new"
        end
      end
    end
  end

end
