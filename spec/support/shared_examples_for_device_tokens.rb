shared_examples "a DeviceToken subclass" do

  it 'can be created' do
    device_token.should_not be_nil
  end

  it 'should have a user' do
    device_token.user.should_not be_nil
  end

  it 'should respond to #device_id' do
    device_token.should respond_to(:device_id)
  end

  it '#device_id should return the device_token' do
    device_token.device_id.should eq("asdf1234")
  end

end