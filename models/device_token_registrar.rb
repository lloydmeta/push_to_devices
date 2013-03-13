#encoding: utf-8

# Command class handling Device token (APN and GCM) registration
# for a user
class DeviceTokenRegistrar

  attr_accessor :service, :unique_hash, :apn_device_token, :gcm_registration_id

  def initialize(params)
    initialisation_params = params
    self.service = initialisation_params[:service]
    self.unique_hash = initialisation_params[:unique_hash]
    self.apn_device_token = initialisation_params[:apn_device_token]
    self.gcm_registration_id = initialisation_params[:gcm_registration_id]
    check_attributes
  end

  def register!
    ensure_tokens_currently_unused!
    user_for_unique_hash = get_or_create_user!
    ensure_has_apn_token_registered!(user_for_unique_hash) if apn_device_token
    ensure_has_gcm_token_registered!(user_for_unique_hash) if gcm_registration_id
    user_for_unique_hash
  end

  private

    def check_attributes
      raise "service not provided" if service.nil?
      raise "unique_hash not provided" if unique_hash.nil?
      raise "no device tokens supplied" if[apn_device_token, gcm_registration_id].none?
    end

    def ensure_tokens_currently_unused!
      ensure_apn_token_currently_unused! if apn_device_token
      ensure_gcm_id_currently_unused! if gcm_registration_id
    end

    def ensure_apn_token_currently_unused!
      users_with_token = users_holding_token(:apn_device_token)
      remove_old_token_from_users(users_with_token, :apn_device_token)
    end

    def ensure_gcm_id_currently_unused!
      users_with_token = users_holding_token(:gcm_device_token)
      remove_old_token_from_users(users_with_token, :gcm_device_token)
    end

    def users_holding_token(token_type)
      if token_type == :apn_device_token
        service.users.where("apn_device_tokens.apn_device_token" => apn_device_token).all
      elsif token_type == :gcm_device_token
        service.users.where("gcm_device_tokens.gcm_registration_id" => gcm_registration_id).all
      end
    end

    def remove_old_token_from_users(users, token_type)
      users.each do |user|
        if token_type == :apn_device_token
          user.apn_device_tokens.where("apn_device_token" => apn_device_token).destroy_all
        elsif token_type == :gcm_device_token
          user.gcm_device_tokens.where("gcm_registration_id" => gcm_registration_id).destroy_all
        end
      end
    end

    def get_or_create_user!
      service.users.where(
        unique_hash: unique_hash
      ).first_or_create!
    end

    def ensure_has_apn_token_registered!(user)
      if user.apn_device_tokens.where(apn_device_token: apn_device_token).empty?
        user.apn_device_tokens.build(apn_device_token: apn_device_token).save!
      end
    end

    def ensure_has_gcm_token_registered!(user)
      if user.gcm_device_tokens.where(gcm_registration_id: gcm_registration_id).empty?
        user.gcm_device_tokens.build(gcm_registration_id: gcm_registration_id).save!
      end
    end

end