require "api_auth"

PushToDeviceServer.controllers :services do
  include ApiAuth

  before do
    api_authenticate
  end

  get :me, :map => "/services/me", :provides => :json do
    content_type :json
    @service = api_current_user
    @service.to_json
  end

end
