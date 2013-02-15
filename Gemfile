source :rubygems

# Server requirements
# gem 'thin' # or mongrel
# gem 'trinidad', :platform => 'jruby'

# Project requirements
gem 'rake'
gem 'sinatra-flash', :require => 'sinatra/flash'

# Component requirements
gem 'bcrypt-ruby', :require => "bcrypt"
gem 'haml'
gem 'mongoid', :git => "git://github.com/mongoid/mongoid.git", :branch => "master"
gem 'bson_ext', :require => "mongo"
gem 'mongo', :require => 'mongo'

# Redis, Resque, Resque-scheduler
gem "redis"
gem "resque", :require => 'resque/server'
gem 'resque-scheduler', :require => 'resque_scheduler'

# Gem for pushing notifications to Apple and Google
gem 'pushmeup', :git => "git@github.com:lloydmeta/pushmeup.git", :branch => "hotfix/allow_sending_custom_gcm_host"

# PEM File upload
gem 'carrierwave'
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'

# Test requirements
group "test" do
  gem 'rspec'
  gem 'rack-test', :require => "rack/test"
  gem 'factory_girl'
  gem 'database_cleaner'
  gem 'faker'
  gem 'webrat'
  gem 'webmock'
end


# Padrino Stable Gem
gem 'padrino', '0.10.7'

# Or Padrino Edge
# gem 'padrino', :git => 'git://github.com/padrino/padrino-framework.git'

# Or Individual Gems
# %w(core gen helpers cache mailer admin).each do |g|
#   gem 'padrino-' + g, '0.10.7'
# end
