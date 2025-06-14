include "root" {
  path = find_in_parent_folders()
}

dependency "infra" {
  config_path = "${get_terragrunt_dir()}/../infra-components"
}


inputs = {
  log_workspace_id = dependency.infra.outputs.log_workspace.id
}