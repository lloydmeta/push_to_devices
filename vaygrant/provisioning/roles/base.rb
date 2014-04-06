name "push_to_devices_base_server"

description "Base for push_to_devices servers"

run_list(
  "recipe[chef-locale::default]",
  "recipe[apt::default]"
)
