# encoding: utf-8
class Notification
  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields

  # field <name>, :type => <type>, :default => <value>
  field :ios_specific_fields, :type => String
  field :android_specific_fields, :type => String

  validate :fields_all_json

  embedded_in :user

  DEFAULT_NOTIFICATION = {alert: "Hi", badge: 1, sound: "default"}

  # You can define indexes on documents using the index macro:
  # index :field <, :unique => true>

  # You can create a composite key in mongoid to replace the default id using the key macro:
  # key :field <, :another_field, :one_more ....>

  def ios_version
    if ! ios_specific_fields.empty?
      DEFAULT_NOTIFICATION.merge(JSON.parse(ios_specific_fields).symbolize_keys)
    else
      {}
    end
  end

  def android_version
    if ! android_specific_fields.empty?
      JSON.parse(android_specific_fields).symbolize_keys
    else
      {}
    end
  end

  private
    def fields_all_json
      [ios_specific_fields, android_specific_fields].each do |field|
        begin
          JSON.parse(field) unless field.nil? || field.empty?
        rescue
          errors.add :base, "Invalid JSON: #{field}"
        end
      end
    end
end
