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

    @service_user = api_current_user.users.where(
      unique_hash: params["unique_hash"]
    ).first_or_create!

    if params[:apn_device_token]
      @service_user.apn_device_tokens.where(
        apn_device_token: params["apn_device_token"]
      ).first_or_create!
    end

    if params[:gcm_registration_id]
      @service_user.gcn_device_tokens.where(
        gcm_registration_id: params["gcm_registration_id"]
      ).first_or_create!
    end

    @service_user.to_json
  end

end
