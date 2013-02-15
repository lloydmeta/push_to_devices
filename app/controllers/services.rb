require "api_auth"

PushToDeviceServer.controllers :services do
  include ApiAuth

  before do
    api_authenticate
  end

  get :me, :map => "/services/me", :provides => :json do
    content_type :json
    @service = api_current_user
    {
      :name => @service.name,
      :server_client_id => @service.server_client_id,
      :server_client_secret => @service.server_client_secret,
      :mobile_client_id => @service.mobile_client_id,
      :mobile_client_secret => @service.mobile_client_secret
    }.to_json
  end

end
