locals {
  env_path       = "${get_parent_terragrunt_dir()}/../environments/"
  env_config     = read_terragrunt_config("${local.env_path}/${get_env("TF_VAR_environment")}/environments.hcl").inputs
  workspace_path = trimsuffix(path_relative_to_include(), "/")
  file_name      = lower("${get_env("TF_VAR_environment")}/${local.workspace_path}/terraform.tfstate")
  var_file       = "${get_parent_terragrunt_dir()}/../environments/${get_env("TF_VAR_environment")}/${local.workspace_path}.tfvars"
}

remote_state {
  backend = "azurerm"
  config = {
    resource_group_name  = local.env_config.remote_state_rg
    storage_account_name = local.env_config.remote_state_account_name
    container_name       = "tfstate"
    key                  = local.file_name
    subscription_id      = local.env_config.subscription_id
    tenant_id            = local.env_config.tenant_id
  }
  /***********************************************************************************************************************
  * NOTE:-
  * Due to the Terragrunt binary not officially supporting the current capabilities and features in the latest version of
  * Terraform (>= 1.0.0) when a dependent directory has configuration persisted (.terraform) and the configuration for
  * remote state is dynamic - using environment variables - a failure persists demanding backend initialisation
  * irrespective of whether it has or hasn't already been initialised.
  *
  * REF: https://github.com/gruntwork-io/terragrunt/issues/1330
  ***********************************************************************************************************************/
  disable_dependency_optimization = true
}


terraform {
  extra_arguments "input_vars" {
    commands = get_terraform_commands_that_need_vars()
    optional_var_files = [
      local.var_file
    ]
    env_vars = {
      HELM_HOME              = "${get_parent_terragrunt_dir()}/.helm/${get_env("TF_VAR_environment")}"
      HELM_REPOSITORY_CONFIG = "${get_parent_terragrunt_dir()}/.helm/${get_env("TF_VAR_environment")}/repository"
      HELM_REGISTRY_CONFIG   = "${get_parent_terragrunt_dir()}/.helm/${get_env("TF_VAR_environment")}/registry"
      TF_VAR_environment     = get_env("TF_VAR_environment")
      TF_VAR_product         = try(local.env_config.product, "ng")
    }
  }
}
