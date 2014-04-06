name "mongodb_node"

description "A node that has mongodb installed"

run_list(
  "recipe[mongodb::push_to_devices_mongodb]"
)
