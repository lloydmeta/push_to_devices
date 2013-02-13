require 'spec_helper'

describe "Notification Model" do

  let(:notification) {
    user = FactoryGirl.create(:user)
    user.notifications.build(
      message: {random_hash_key: "random value"}.to_json,
      badge: 5
    )
  }

  it 'can be created' do
    notification.should_not be_nil
  end

  it 'should have a user' do
    notification.user.should_not be_nil
  end

end
