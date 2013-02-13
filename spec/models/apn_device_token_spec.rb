require 'spec_helper'

describe "ApnDeviceToken Model" do

  it_should_behave_like "a DeviceToken subclass" do

    let(:device_token) {
      user = FactoryGirl.create(:user)
      user.apn_device_tokens.build(apn_device_token: "asdf1234")
    }
  end

end
