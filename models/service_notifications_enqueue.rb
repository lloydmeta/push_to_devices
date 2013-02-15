#encoding: utf-8
module ServiceNotificationsEnqueue
  @queue = :high

  def self.perform(interval)
    Service.where(interval: interval.to_i).all.each do |service|
      service.async_send_notifications_to_users
    end
  end

end