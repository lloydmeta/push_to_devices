# encoding utf-8

# Class that destructively (!!!) sends notifications for a group of users using
# a buffer and send method. When send! is called, notifications for the users
# passed in will be looped over, sent, and then destroyed
class NotificationsBufferedSender

  NOTIFICATIONS_BUFFER_THRESHOLD = Padrino.env == :test ? 50 : 500

  attr_accessor :users, :apn_connection, :gcm_connection, :notifications_buffer

  def initialize(params)
    self.users = params[:users]
    self.apn_connection = params[:apn_connection]
    self.gcm_connection = params[:gcm_connection]
    self.notifications_buffer = []

    nil_arguments = [:users, :apn_connection, :gcm_connection].select{|x| send(x).nil?}
    raise ArgumentError, "#{nil_arguments} not provided" if ! nil_arguments.empty?
  end

  def send!
    users.each do |user|
      # user.notifications.all.each? or use .cache?
      # Depends on how the Mongoid cursor wrapper
      # works. .each by itself does pagination built in
      user.notifications.order_by(:created_at.asc).all.each do |notification|
        add_to_buffer!(notification)
      end
    end
    send_and_destroy_notifications_in_buffer!
    true
  end

  private

    def send_and_destroy_notifications_in_buffer!
      if notifications_buffer.length > 0
        send_notifications(:ios)
        send_notifications(:android)
        destroy_notifications_in_buffer!
      end
    end

    def destroy_notifications_in_buffer!
      notifications_buffer.each do |notification|
        notification.destroy
      end
      notifications_buffer.clear
    end

    def add_to_buffer!(notification)
      self.notifications_buffer << notification
      if notifications_buffer.length >= NOTIFICATIONS_BUFFER_THRESHOLD
        send_and_destroy_notifications_in_buffer!
      end
    end

    def send_notifications(type)
      begin
        formatted_notifications = notifications_buffer.map {|notification|
          notification.sendable(type)
        }.flatten.compact

        if ! formatted_notifications.empty?
          if type == :ios
            apn_connection.send_notifications(formatted_notifications)
          elsif type == :android
            gcm_connection.send_notifications(formatted_notifications)
          end
        end
      rescue => e
        Padrino::logger.info e
        Padrino::logger.info e.backtrace
      end
    end

end
