#encoding: utf-8

# Command class for generating types of notifications for
# an array of users

class NotificationsGenerator

  DEFAULT_PARAMS = {users: []}

  attr_accessor :users

  def initialize(params)
    initialisation_params = DEFAULT_PARAMS.merge(params)
    @users = initialisation_params[:users]
  end

  def notifications(type = :ios)
    @notifications ||= begin
      if type == :ios
        ios_notifications_for_users
      elsif type == :android
        android_notifications_for_users
      else
        raise "illegal type #{type}"
      end
    end
  end

  def ios_notifications_for_users
    @users.map {|user|
      ios_notifications_for_user(user)
    }.flatten.compact
  end

  def ios_notifications_for_user(user)
    if user.apn_device_tokens.empty? || user.notifications.empty?
      nil
    else
      user.notifications.order_by(:created_at.asc).map do |noti|
        user.apn_device_tokens.reduce([]){|ios_notis, apn_device_token|
          APNS::Notification.new(apn_device_token, noti.ios_version)
        }
      end
    end
  end

  def android_notifications_for_users
    @users.map {|user|
      android_notifications_for_user(user)
    }.compact
  end

  def android_notifications_for_user(user)
    if user.gcm_device_tokens.empty? || user.notifications.empty?
      nil
    else
      user.notifications.order_by(:created_at.asc).map do |noti|
        android_noti = noti.android_version
        android_noti_options = android_noti.delete(:options) || {}
        GCM::Notification.new(user.gcm_device_tokens.map(&:device_id), android_noti, android_noti_options)
      end
    end
  end

end