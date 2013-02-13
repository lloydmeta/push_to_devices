require "api_auth"

PushToDeviceServer.controllers :users do
  include ApiAuth

  before do
    api_authenticate
  end

  # for receiving POST requests to /users/
  # expects params to be JSON, with at least unique_hash
  # as well as optionally apn_device_token and/or gcm_registration_id
  post :create, :map => "/users/", :provides => :json do
    content_type :json

    error 433, {error: "unique_hash not provided"}.to_json unless params["unique_hash"]

    @service_user = api_current_user.users.where(
      unique_hash: params["unique_hash"]
    ).first_or_create!

    if params["apn_device_token"]
      if @service_user.apn_device_tokens.where(apn_device_token: params["apn_device_token"]).empty?
        @service_user.apn_device_tokens.build(apn_device_token: params["apn_device_token"]).save!
      end
    end

    if params["gcm_registration_id"]
      if @service_user.gcm_device_tokens.where(gcm_registration_id: params["gcm_registration_id"]).empty?
        @service_user.gcm_device_tokens.build(gcm_registration_id: params["gcm_registration_id"]).save!
      end
    end

    @service_user.to_json
  end

end
