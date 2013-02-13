class ApnDeviceToken < DeviceToken

  # field <name>, :type => <type>, :default => <value>
  field :apn_device_token, :type => String

  embedded_in :user

  # You can define indexes on documents using the index macro:
  # index :field <, :unique => true>

  # You can create a composite key in mongoid to replace the default id using the key macro:
  # key :field <, :another_field, :one_more ....>

  def device_id
    apn_device_token
  end
end
