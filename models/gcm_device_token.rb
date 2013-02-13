class GcmDeviceToken < DeviceToken

  # field <name>, :type => <type>, :default => <value>
  field :gcm_registration_id, :type => String

  # You can define indexes on documents using the index macro:
  # index :field <, :unique => true>

  # You can create a composite key in mongoid to replace the default id using the key macro:
  # key :field <, :another_field, :one_more ....>

  embedded_in :user

  def device_id
    gcm_registration_id
  end
end
