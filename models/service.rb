# encoding: utf-8
require 'securerandom'

class Service
  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields

  # field <name>, :type => <type>, :default => <value>
  field :name, :type => String # name of the service registerd to this push server
  field :description, :type => String
  field :interval, :type => Integer #interval at which to run notifications
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
        # apn_connection.send(ios_notifications)
        # gcm_connection.send(android_notifications)
        rescue
          true
        ensure
          notifications_generator.clear_users_notifications!
        end
    end
  end

  def apn_connection
    #stub
    @apn_connection ||= begin
      Object.new
    end
  end

  def gcm_connection
    #stub
    @gcm_connection ||= begin
      Object.new
    end
  end

end
