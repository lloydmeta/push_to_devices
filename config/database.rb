config_file = Padrino.root("config", "mongoid.yml")
if File.exists?(config_file)
  Mongoid.load!(config_file, ENV["RACK_ENV"])
end