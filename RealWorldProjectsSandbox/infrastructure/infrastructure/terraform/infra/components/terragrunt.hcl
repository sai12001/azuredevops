include "root" {
  path = find_in_parent_folders()
}

dependency "root" {
  config_path = "../root"
}

inputs = {
  shared_vnet_config = dependency.root.outputs.shared_vnet_config
  rg_infra = dependency.root.outputs.shared_infra_rg
}
