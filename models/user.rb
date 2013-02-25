# encoding: utf-8
class User
  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields

  # field <name>, :type => <type>, :default => <value>
  field :unique_hash, :type => String
  field :notifications_count, :type => Integer

  # You can define indexes on documents using the index macro:
  index({ unique_hash: 1}, {unique: true})

  belongs_to :service
  embeds_many :apn_device_tokens
  embeds_many :gcm_device_tokens
  embeds_many :notifications

  # You can create a composite key in mongoid to replace the default id using the key macro:
  # key :field <, :another_field, :one_more ....>

end
