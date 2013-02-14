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

# Test requirements
gem 'rspec', :group => "test"
gem 'rack-test', :require => "rack/test", :group => "test"
gem 'factory_girl', :group => 'test'
gem 'database_cleaner', :group => 'test'
gem 'faker', :group => 'test'

# Padrino Stable Gem
gem 'padrino', '0.10.7'

# Or Padrino Edge
# gem 'padrino', :git => 'git://github.com/padrino/padrino-framework.git'

# Or Individual Gems
# %w(core gen helpers cache mailer admin).each do |g|
#   gem 'padrino-' + g, '0.10.7'
# end
