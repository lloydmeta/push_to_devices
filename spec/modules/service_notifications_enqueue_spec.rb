require 'spec_helper'

describe "Service Notifications Enqueue module" do

  describe ".perform" do

    context "with proper interval as an argument" do

      it "should cause relevant services to receive send_notifications_to_users" do
        Service.create!(:name => "5 min 1", :interval => 5)
        Service.any_instance.should_receive(:send_notifications_to_users)
        ServiceNotificationsEnqueue.perform(5)
      end

      it "should not cause irrelevant services to receive send_notifications_to_users" do
        Service.create!(:name => "5 min 1", :interval => 10)
        Service.any_instance.should_not_receive(:send_notifications_to_users)
        ServiceNotificationsEnqueue.perform(5)
      end

    end

  end

end
