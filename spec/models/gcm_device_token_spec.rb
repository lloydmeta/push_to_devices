require 'spec_helper'

describe "GcmDeviceToken Model" do

  it_should_behave_like "a DeviceToken subclass" do

    let(:device_token) {
      user = FactoryGirl.create(:user)
      user.gcm_device_tokens.build(gcm_registration_id: "asdf1234")
    }
  end

end
