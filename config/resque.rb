Resque.redis = Redis::Namespace.new(:push_noti_resque, :redis => $redis)
Resque.schedule = YAML.load_file(Padrino.root("config", "resque_schedule.yml"))