require 'spec_helper'

describe "User Model" do

  let(:user) {
    service = FactoryGirl.create(:service)
    service.users.build(unique_hash: "asdf1234")
  }

  it 'can be created' do
    user.should_not be_nil
  end

  it 'should have a service' do
    user.service.should_not be_nil
  end

  it 'should have a unique_hash' do
    user.unique_hash.should eq('asdf1234')
  end
end
