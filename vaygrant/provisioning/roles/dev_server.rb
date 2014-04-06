name "push_to_devices_server"

description "A server running MongoDB and Redis"

run_list(
  "role[base]",
  "role[rvm_node]",
  "role[mongodb_node]",
  "role[redis_node]"
)
