require 'spec_helper'

describe "NotificationsBufferedSender" do

  let(:users){
    double("le_users")
  }

  let(:apn_connection){
    double("le_apn_connection", :send_notifications => {})
  }

  let(:gcm_connection){
    double("le_gcm_connection", :send_notifications => {})
  }

  describe "#initialize" do

    it "should raise errors when not given a users" do
      expect {
        NotificationsBufferedSender.new(apn_connection: apn_connection, gcm_connection: gcm_connection)
      }.to raise_error(ArgumentError)
    end

    it "should raise errors when not given a apn_connection" do
      expect {
        NotificationsBufferedSender.new(users: users, gcm_connection: gcm_connection)
      }.to raise_error(ArgumentError)
    end

    it "should raise errors when not given a gcm_connection" do
      expect {
        NotificationsBufferedSender.new(apn_connection: apn_connection, users: users)
      }.to raise_error(ArgumentError)
    end

    it "should not raise errors when given everything required" do
      expect {
        NotificationsBufferedSender.new(
          apn_connection: apn_connection,
          users: users,
        gcm_connection: gcm_connection)
      }.to_not raise_error(ArgumentError)
    end

  end

  describe "#send!" do

    let(:notifications_buffered_sender){
      NotificationsBufferedSender.new(
        users: users,
        apn_connection: apn_connection,
        gcm_connection: gcm_connection)}

    it "should exist" do
      notifications_buffered_sender.should respond_to(:send!)
    end

    it "should iterate on the users given"  do
      users.should_receive(:each)
      notifications_buffered_sender.send!
    end

    context "sending" do

      let(:users_with_notifications){
        3.times.map do
          FactoryGirl.create(:user_with_tokens)
        end
      }

      before(:each) do
        @notifications = users_with_notifications.map {|user|
          NotificationsBufferedSender::NOTIFICATIONS_BUFFER_THRESHOLD.times.map do
            FactoryGirl.create(:notification, user: user)
          end
        }.flatten

        @notifications_buffered_sender =  NotificationsBufferedSender.new(
          users: users_with_notifications,
          apn_connection: apn_connection,
          gcm_connection: gcm_connection
        )
      end

      it "should call #send_notifications on apn_connection" do
        apn_connection.should_receive(:send_notifications).exactly(@notifications.size / NotificationsBufferedSender::NOTIFICATIONS_BUFFER_THRESHOLD).times
        @notifications_buffered_sender.send!
      end

      it "should call #send_notifications on gcm_connection" do
        gcm_connection.should_receive(:send_notifications).exactly(@notifications.size / NotificationsBufferedSender::NOTIFICATIONS_BUFFER_THRESHOLD).times
        @notifications_buffered_sender.send!
      end

      it "should clear all notifications for users" do
        @notifications_buffered_sender.send!
        users_with_notifications do |user|
          user.notifications.count.should eq 0
        end
      end

    end

  end

end
