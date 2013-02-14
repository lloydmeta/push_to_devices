redis_config = YAML.load_file(Padrino.root("config", "redis.yml"))[PADRINO_ENV]

# Connect to Redis using the redis_config host and port
if redis_config
  opts = {host: redis_config['host'], port: redis_config['port'], db:redis_config['db']}

  if PADRINO_ENV == "development"
    opts[:logger] = Padrino::logger
  end

  $redis = Redis.new(opts)
else
  Padrino::logger.fatal "No Redis config detected!"
end