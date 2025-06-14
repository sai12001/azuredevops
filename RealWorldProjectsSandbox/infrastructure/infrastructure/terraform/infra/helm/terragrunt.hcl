include "root" {
  path = find_in_parent_folders()
}

dependency "aks" {
  config_path = "${get_terragrunt_dir()}/../aks"
}


inputs = {
  aks = dependency.aks.outputs.aks_cluster_config
}