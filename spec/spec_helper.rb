PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")
require 'webmock/rspec'

FactoryGirl.definition_file_paths = [
    File.join(Padrino.root, 'factories'),
    File.join(Padrino.root, 'test', 'factories'),
    File.join(Padrino.root, 'spec', 'factories')
]

FactoryGirl.find_definitions

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir["#{Padrino.root}/spec/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.include ApiAuthHelper, :type => :controller

  config.before(:suite) do
    WebMock.enable!
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
    WebMock.reset!
    WebMock.disable_net_connect!
    stub_request(:any, /.*/).to_return(:body => {status: "ok"}.to_json)
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:suite) do
      FileUtils.rm_rf(Dir["#{Padrino.root}/uploads/#{Padrino.env}/"])
  end
end

def app
  ##
  # You can handle all padrino applications using instead:
  #   Padrino.application
  PushToDeviceServer.tap { |app|  }
end

# equality overrides for notifications
module APNS
  class Notification

    def ==(that)
      device_token == that.device_token &&
      alert == that.alert &&
      badge == that.badge &&
      sound == that.sound &&
      other == that.other
    end
  end
end

module GCM
  class Notification

    def ==(that)
      device_tokens == that.device_tokens &&
      data == that.data &&
      collapse_key == that.collapse_key &&
      time_to_live == that.time_to_live &&
      delay_while_idle == that.delay_while_idle &&
      identity == that.identity
    end
  end
end

