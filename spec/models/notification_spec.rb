require 'spec_helper'

describe "Notification Model" do

  let(:notification) {
    user = FactoryGirl.create(:user)
    user.notifications.build(
      message: {random_hash_key: "random value"}.to_json,
    )
  }

  it 'can be created' do
    notification.should_not be_nil
  end

  it 'should have a user' do
    notification.user.should_not be_nil
  end

  context "validations" do

    describe "message" do

      let(:user){FactoryGirl.create(:user)}

      it "should not be valid if it is not present" do
        notification = user.notifications.build
        notification.should_not be_valid
      end

      it "should not be valid if it is empty" do
        notification = user.notifications.build(message: "")
        notification.should_not be_valid
      end

      it "should be valid if it is a valid JSON string" do
        message = {value: 3}.to_json
        notification = user.notifications.build(message: message)
        notification.should be_valid
      end

      it "should not be valid if it is not a valid JSON string" do
        broken_message = {value: 3}.to_json.chop
        notification = user.notifications.build(message: broken_message)
        notification.should_not be_valid
      end

    end

  end

end
