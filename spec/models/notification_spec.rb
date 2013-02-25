require 'spec_helper'

describe "Notification Model" do

  let(:ios_specific_fields){
    {random_hash_key: "ios random value"}
  }

  let(:android_specific_fields){
    {
      data: {random_hash_key: "android random value"},
      options: {time_to_live: 200}
    }
  }

  let(:notification) {
    user = FactoryGirl.create(:user)
    user.notifications.build(
      ios_specific_fields: ios_specific_fields.to_json,
      android_specific_fields: android_specific_fields.to_json
    )
  }

  it 'can be created' do
    notification.should_not be_nil
  end

  it 'should have a user' do
    notification.user.should_not be_nil
  end

  context "validations" do

      let(:user){FactoryGirl.create(:user)}

      it "should be valid if it is a valid JSON string" do
        message = {value: 3}.to_json
        notification = user.notifications.build(ios_specific_fields: message)
        notification.should be_valid
      end

      it "should not be valid if it is not a valid JSON string" do
        broken_message = {value: 3}.to_json.chop
        notification = user.notifications.build(ios_specific_fields: broken_message)
        notification.should_not be_valid
      end

  end

  context "instance methods" do

    describe "#ios_version" do

      it "should return a merged hash containing the ios specific fields" do
        notification.ios_version.symbolize_keys.should eq(Notification::DEFAULT_NOTIFICATION_IOS.merge(ios_specific_fields))
      end

    end

    describe "#android_version" do

      it "should return a merged hash containing the android specific fields" do
        notification.android_version.to_json.should eq(android_specific_fields.to_json)
      end

    end

  end

end
