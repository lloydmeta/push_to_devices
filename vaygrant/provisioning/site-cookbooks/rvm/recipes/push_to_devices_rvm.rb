node.default['rvm']['rubies'] = [
  "ruby-2.0.0-p451"
]
node.default['rvm']['default_ruby'] = "ruby-2.0.0-p451"
node.default['rvm']['user_installs'] = [
  { 'user'          => 'vagrant',
    'default_ruby'  => "ruby-2.0.0-p451",
    'global_gems'  => [ ],
    'rubies'        => [ "ruby-2.0.0-p451"]
  }
]

include_recipe "rvm::system"
include_recipe "rvm::user"
include_recipe "rvm::vagrant"
