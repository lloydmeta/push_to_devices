name "rvm_node"

description "A node that has rvm installed"

run_list(
  "recipe[rvm::push_to_devices_rvm]"
)
