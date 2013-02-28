require 'spec_helper'

describe "DeviceTokenRegistrar" do

  describe "creation" do

    it "should work if service, unique_hash, and apn_device_token or gcm_registration_id are supplied" do
      expect{
        DeviceTokenRegistrar.new(service: "blah", unique_hash: "blah", apn_device_token: "asdfa")
      }.to_not raise_error

      expect{
        DeviceTokenRegistrar.new(service: "blah", unique_hash: "blah", gcm_registration_id: "asdfa")
      }.to_not raise_error

      expect{
        DeviceTokenRegistrar.new(service: "blah", unique_hash: "blah", gcm_registration_id: "asdfa", apn_device_token: "asdfa")
      }.to_not raise_error
    end

    it "should raise an error if service is missing" do
      expect{
        DeviceTokenRegistrar.new(unique_hash: "blah", apn_device_token: "asdfa")
      }.to raise_error
    end

    it "should raise an error if unique_hash is missing" do
      expect{
        DeviceTokenRegistrar.new(service: "blah", apn_device_token: "asdfa")
      }.to raise_error
    end

    it "should raise an error if both apn_device_token and gcm_registration_id are missing" do
      expect{
        DeviceTokenRegistrar.new(service: "blah", unique_hash: "asdfa")
      }.to raise_error
    end

  end

  describe "#register!" do

    it "should exist" do
      DeviceTokenRegistrar.new(service: "blah", unique_hash: "blah", apn_device_token: "asdfa").should respond_to(:register!)
    end

    context "with actual service" do

      before(:each) do
        @service = FactoryGirl.create(:service)
      end

      context "and a new user_hash" do

        before(:each) do
          @apn_token = "apntokentoken"
          @gcm_registration_id = "gcmidid"
          @device_token_registrar_apn = DeviceTokenRegistrar.new(service: @service, unique_hash: "hashhash", apn_device_token: @apn_token)
          @device_token_registrar_gcm = DeviceTokenRegistrar.new(service: @service, unique_hash: "hashhash", gcm_registration_id: @gcm_registration_id)
          @device_token_registrar_apn_gcm = DeviceTokenRegistrar.new(service: @service, unique_hash: "hashhash", apn_device_token: @apn_token, gcm_registration_id: @gcm_registration_id)
        end

        it "should create a new user" do
          expect{
            @device_token_registrar_apn.register!
          }.to change(User, :count).by(1)
        end

        it "should create a new user for the service" do
          user = @device_token_registrar_apn.register!
          user.service.should eq(@service)
        end

        it "should create an apn token on the user if provided with one" do
          user = @device_token_registrar_apn.register!
          user.apn_device_tokens.size.should eq(1)
        end

        it "should create an apn token on the user properly if provided with one" do
          user = @device_token_registrar_apn.register!
          user.apn_device_tokens.first.device_id.should eq(@apn_token)
        end

        it "should create an gcm token on the user if provided with one" do
          user = @device_token_registrar_gcm.register!
          user.gcm_device_tokens.size.should eq(1)
        end

        it "should create an gcm token on the user properly if provided with one" do
          user = @device_token_registrar_gcm.register!
          user.gcm_device_tokens.first.device_id.should eq(@gcm_registration_id)
        end

        it "should create an apn token AND a gcm token on the user if provided with both" do
          user = @device_token_registrar_apn_gcm.register!
          user.apn_device_tokens.size.should eq(1)
          user.gcm_device_tokens.size.should eq(1)
        end

        it "should create an gcm token on the user properly if provided with one" do
          user = @device_token_registrar_apn_gcm.register!
          user.apn_device_tokens.first.device_id.should eq(@apn_token)
          user.gcm_device_tokens.first.device_id.should eq(@gcm_registration_id)
        end

        it "should not create 2 users for when using the same @service and same unique_hash" do
          @device_token_registrar_apn_gcm.register!
          expect{
            @device_token_registrar_apn_gcm.register!
          }.to_not change(User, :count)
        end

        it "should create 2 users when using different services despite the same unique_hash" do
          another_service = FactoryGirl.create(:service)
          another_device_token_registrar_apn = DeviceTokenRegistrar.new(service: another_service, unique_hash: "hashhash", apn_device_token: @apn_token)
          expect{
            @device_token_registrar_apn_gcm.register!
            another_device_token_registrar_apn.register!
          }.to change(User, :count).by(2)
        end

        context "but OLD device tokens" do

          before(:each) do
            @old_user = @device_token_registrar_apn.register!
            @device_token_registrar_gcm.register!
            @device_token_registrar_apn_2 = DeviceTokenRegistrar.new(service: @service, unique_hash: "hashhash2", apn_device_token: @apn_token)
            @device_token_registrar_gcm_2 = DeviceTokenRegistrar.new(service: @service, unique_hash: "hashhash2", gcm_registration_id: @gcm_registration_id)
          end

          it "should remove the APN token from the old user who used to hold it" do
            @device_token_registrar_apn_2.register!
            @old_user.reload
            @old_user.apn_device_tokens.size.should eq(0)
          end

          it "should add the APN token to the newly registered user" do
            user = @device_token_registrar_apn_2.register!
            user.apn_device_tokens.first.device_id.should eq(@apn_token)
          end

          it "should remove the GCM token from the old user who used to hold it" do
            @device_token_registrar_gcm_2.register!
            @old_user.reload
            @old_user.gcm_device_tokens.size.should eq(0)
          end

          it "should add the GCM token to the newly registered user" do
            user = @device_token_registrar_gcm_2.register!
            user.gcm_device_tokens.first.device_id.should eq(@gcm_registration_id)
          end

        end

      end

    end

  end

end
