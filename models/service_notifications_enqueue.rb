#encoding:
module ServiceNotificationsEnqueue
  @queue = :high

  def self.perform(interval)
    Service.where(interval: interval.to_i).all.each do |service|
      service.queue_notifications_for_users
    end
  end

end