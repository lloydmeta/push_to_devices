# encoding: utf-8
require 'securerandom'
require 'carrierwave/mongoid'

class Service
  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields

  mount_uploader :pemfile, PemfileUploader

  # field <name>, :type => <type>, :default => <value>
  field :name, :type => String # name of the service registerd to this push server
  field :description, :type => String
  field :interval, :type => Integer, default: 5 #interval at which to run notifications
  field :apn_host, :type => String
  field :apn_port, :type => Integer
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

  validates :gcm_api_key, :presence => true

  has_many :users

  # You can create a composite key in mongoid to replace the default id using the key macro:
  # key :field <, :another_field, :one_more ....>

  def self.securerandom_string(n = 23)
    SecureRandom.urlsafe_base64(n, true)
  end

  def async_send_notifications_to_users
    if Padrino.env == :test
      send_notifications_to_users
    else
      Queue::High.enqueue(self, :send_notifications_to_users)
    end
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
        rescue => e
          Padrino::logger.info e
          Padrino::logger.info e.backtrace
        ensure
          notifications_generator.clear_users_notifications!
        end
    end
  end

  def async_delete_user_apn_tokens_based_on_apple_feedback
    if Padrino.env == :test
      delete_user_apn_tokens_based_on_apple_feedback
    else
      Queue::Low.enqueue(self, :delete_user_apn_tokens_based_on_apple_feedback)
    end
  end

  def delete_user_apn_tokens_based_on_apple_feedback
    invalid_tokens = get_apn_feedback.map{|f|f[:token]}
    users.all.each do |u|
      u.apn_device_tokens.where(:apn_device_token.in => invalid_tokens).delete_all
    end
  end

  def apn_connection
    @apn_connection ||= begin
      connection = APNS.clone
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
      connection = GCM.clone
      connection.host = gcm_host if gcm_host && !gcm_host.empty?
      connection.key = gcm_api_key
      connection
    end
  end

  def has_pemfile?
    pemfile.present?
  end

  def apn_pem_path
    pemfile.current_path.gsub("/public/uploads", "/uploads")
  end

  def send_apn_notifications(notifications)
    apn_connection.send_notifications(notifications) unless notifications.nil? || notifications.empty?
  end

  def get_apn_feedback
    apn_connection.feedback
  end

  def send_gcm_notifications(notifications)
    gcm_connection.send_notifications(notifications) unless notifications.nil? || notifications.empty?
  end

end
