name "redis_node"

description "A node that has Redis installed"

run_list *%w[
  recipe[redisio::install]
  recipe[redisio::enable]
]

default_attributes({})