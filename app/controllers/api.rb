require "api_auth"

PushToDeviceServer.controllers :api do
  include ApiAuth

  before do
    api_authenticate
  end

  get :base, :map => "/", :provides => :json do
    content_type :json
    @service = api_current_user
    @service.to_json
  end

end
