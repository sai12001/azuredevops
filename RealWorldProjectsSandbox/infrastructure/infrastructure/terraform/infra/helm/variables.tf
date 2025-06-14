variable "aks" {
  description = "the cluster configuration from upstream. injected automatically"
  type = object({
    name           = string
    resource_group = string
  })

}
