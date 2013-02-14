require 'spec_helper'

describe "Notification Model" do

  let(:default_message){
    {random_hash_key: "random value"}
  }

  let(:notification) {
    user = FactoryGirl.create(:user)
    user.notifications.build(
      message: default_message.to_json,
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

  context "instance methods" do

    describe "#ios_version" do

      it "should return a merged hash containing the main message and the ios specific fields" do
        ios_specific_fields = {ios_stuff: "hi"}
        notification.ios_specific_fields=ios_specific_fields.to_json
        notification.ios_version.symbolize_keys.should eq(default_message.merge(ios_specific_fields))
      end

    end

    describe "#android_version" do

      it "should return a merged hash containing the main message and the android specific fields" do
        android_specific_fields = {android_stuff: "hi"}
        notification.android_specific_fields=android_specific_fields.to_json
        notification.android_version.symbolize_keys.should eq(default_message.merge(android_specific_fields))
      end

    end

  end

end
