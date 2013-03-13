require 'spec_helper'

describe "ApnDeviceToken Model" do

  let(:device_token) {
    user = FactoryGirl.create(:user)
    user.apn_device_tokens.build(apn_device_token: "asdf1234")
  }

  it_should_behave_like "a DeviceToken subclass"

  describe "#increment_feedback_fail_count" do

    it "should exist" do
      device_token.should respond_to(:increment_feedback_fail_count)
    end

    it "should change the feedback_fail_count by 1" do
      expect{
        device_token.increment_feedback_fail_count
      }.to change(device_token, :feedback_fail_count).by(1)
    end

  end

  describe "#decrement_feedback_fail_count" do

    it "should exist" do
      device_token.should respond_to(:decrement_feedback_fail_count)
    end

    it "should change the feedback_fail_count by -1" do
      expect{
        device_token.decrement_feedback_fail_count
      }.to change(device_token, :feedback_fail_count).by(-1)
    end

  end

end
