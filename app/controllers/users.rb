require "api_auth"

PushToDeviceServer.controllers :users do
  include ApiAuth
  include CorsHelpers

  before :except => :corspreflight do
    api_authenticate
  end

  # preflight CORS
  options :corspreflight, :map => '/users/' do
    cors_headers
    " "
  end

  # for receiving POST requests to /users/
  # expects params to be JSON, with at least unique_hash
  # as well as optionally apn_device_token and/or gcm_registration_id
  post :create, :map => "/users/", :provides => :json do
    cors_headers
    content_type :json
    begin
      data=JSON.parse(request.body.read.to_s)
    rescue
      halt 422, {error: "invalid json"}.to_json
    end

    halt 422, {error: "unique_hash not provided"}.to_json unless data["unique_hash"]

    @service_user = DeviceTokenRegistrar.new(
      service: api_current_user,
      unique_hash: data["unique_hash"],
      apn_device_token: data["apn_device_token"],
      gcm_registration_id: data["gcm_registration_id"]
    ).register!

    @service_user.to_json
  end

  # for receiving POST requests to /users/{unique_hash}/notifications
  # Allows for services to create notifications for specific users based on a
  # shared unique hash
  # expects params to be JSON, with at least unique_hash
  # as well as optionally apn_device_token and/or gcm_registration_id
  post :create_notifications, :map => "/users/:unique_hash/notifications", :provides => :json do
    content_type :json

    begin
      data=JSON.parse(request.body.read.to_s)
    rescue
      halt 422, {error: "invalid json"}
    end

    halt 422, {error: "unique_hash not provided"}.to_json unless params[:unique_hash]

    #find the user specified for this service
    @service_user = api_current_user.users.where(
      unique_hash: params[:unique_hash]
    ).first
    halt 200, {error: "specified user does not exist in notification system"}.to_json if @service_user.nil?

    # build the notification
    @service_user_notification = @service_user.notifications.build
    @service_user_notification.ios_specific_fields = data["ios_specific_fields"].to_json if data["ios_specific_fields"]
    @service_user_notification.android_specific_fields = data["android_specific_fields"].to_json if data["android_specific_fields"]

    if @service_user_notification.save
      @service_user_notification.to_json
    else
      halt 422, @service_user_notification.errors.to_json
    end
  end

  # for receiving POST requests to /users/notifications
  # Allows for services to create notifications for a group of users
  # expects params to be JSON, with at least unique_hashes filled in
  # as well as optionally apn_device_token and/or gcm_registration_id
  post :create_notifications_group, :map => "/users/notifications", :provides => :json do
    content_type :json

    begin
      data=JSON.parse(request.body.read.to_s)
    rescue
      halt 422, {error: "invalid json"}
    end

    halt 422, {error: "unique_hashes not provided"}.to_json unless data["unique_hashes"]

    # should be 'reasonably fast' since we're using mongo ;p
    api_current_user.users.where(:unique_hash.in => data["unique_hashes"]).all.each do |service_user|
      service_user_notification = service_user.notifications.build
      service_user_notification.ios_specific_fields = data["ios_specific_fields"].to_json if data["ios_specific_fields"]
      service_user_notification.android_specific_fields = data["android_specific_fields"].to_json if data["android_specific_fields"]
      service_user_notification.save!
    end

    {status: "ok"}.to_json
  end

end
