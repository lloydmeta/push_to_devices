# encoding: utf-8

class ApnDeviceToken < DeviceToken

  # field <name>, :type => <type>, :default => <value>
  field :apn_device_token, :type => String
  field :feedback_fail_count, :type => Integer, :default => 0

  embedded_in :user

  # You can define indexes on documents using the index macro:
  # index :field <, :unique => true>

  # You can create a composite key in mongoid to replace the default id using the key macro:
  # key :field <, :another_field, :one_more ....>

  def device_id
    apn_device_token
  end

  def increment_feedback_fail_count(increment_by = 1)
    inc(:feedback_fail_count, increment_by)
  end

  def decrement_feedback_fail_count(decrement_by = -1)
    increment_feedback_fail_count(decrement_by)
  end

end
