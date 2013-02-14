# encoding: utf-8
require 'securerandom'

class Service
  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields

  # field <name>, :type => <type>, :default => <value>
  field :name, :type => String # name of the service registerd to this push server
  field :description, :type => String
  field :interval, :type => Integer #interval at which to run notifications
  field :apn_host, :type => String
  field :apn_port, :type => Integer
  field :apn_pem_path, :type => String
  field :apn_pem_password, :type => String
  field :gcm_host, :type => String #interval at which to run notifications
  field :gcm_api_key, :type => String #interval at which to run notifications
  field :server_client_id, :type => String, default: ->{Service.securerandom_string}
  field :server_client_secret, :type => String, default: ->{Service.securerandom_string}
  field :mobile_client_id, :type => String, default: ->{Service.securerandom_string}
  field :mobile_client_secret, :type => String, default: ->{Service.securerandom_string}

  # You can define indexes on documents using the index macro:
  index({ server_client_id: 1}, {unique: true})
  index({ mobile_client_id: 1}, {unique: true})

  has_many :users

  # You can create a composite key in mongoid to replace the default id using the key macro:
  # key :field <, :another_field, :one_more ....>

  def self.securerandom_string(n = 23)
    SecureRandom.urlsafe_base64(n, true)
  end

  def send_notifications_to_users
    per_batch = 1000
    0.step(users.count, per_batch) do |offset|
        users_batch = users.limit(per_batch).skip(offset)
        notifications_generator = NotificationsGenerator.new(users: users_batch)
        ios_notifications = notifications_generator.notifications(:ios)
        android_notifications = notifications_generator.notifications(:android)
        begin
          send_apn_notifications(ios_notifications)
          send_gcm_notifications(android_notifications)
        rescue
          true
        ensure
          notifications_generator.clear_users_notifications!
        end
    end
  end

  def apn_connection
    @apn_connection ||= begin
      connection = APNS.dup
      connection.host = apn_host if apn_host && !apn_host.empty?
      connection.port = apn_port if apn_port
      connection.pem = apn_pem_path
      connection.pass = apn_pem_password if apn_pem_password && !apn_pem_password.empty?
      connection
    end
  end

  def gcm_connection
    #stub
    @gcm_connection ||= begin
      connection = GCM.dup
      connection.host = gcm_host if gcm_host && !gcm_host.empty?
      connection.key = gcm_api_key
      connection
    end
  end

  def send_apn_notifications(notifications)
    apn_connection.send(notifications)
  end

  def send_gcm_notifications(notifications)
    gcm_connection.send(notifications)
  end

end
