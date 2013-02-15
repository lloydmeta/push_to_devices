#encoding: utf-8
module ServiceFeedbackEnqueue
  @queue = :high

  def self.perform
    Service.all.each do |service|
      service.async_delete_user_apn_tokens_based_on_apple_feedback
    end
  end

end