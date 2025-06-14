locals {
  tags                                = merge(var.resource_group.tags, var.tags)
  app_gateway_name                    = "${var.context.environment}-${var.context.product}-appgw-${var.context.product}"
  backend_address_pool_name           = "${var.virtual_network_name}-be-ap"
  frontend_port_name                  = "${var.virtual_network_name}-fe-port"
  frontend_ip_configuration_name      = "${var.virtual_network_name}-fe-ip"
  gateway_ip_configuration_name       = "${var.virtual_network_name}-ge-ip-conf"
  frontend_priv_ip_configuration_name = "${var.virtual_network_name}-fe-priv-ip"
  disabled_rule_group_settings_dev_portal = [
    {
      rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
      rules = [
        942100,
        942200,
        942110,
        942180,
        942260,
        942340,
        942370,
        942430,
        942440
      ]
    },
    {
      rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
      rules = [
        920300,
        920330
      ]
    },
    {
      rule_group_name = "REQUEST-931-APPLICATION-ATTACK-RFI"
      rules = [
      931130]
    }
  ]
  disabled_rule_group_settings = var.disable_waf_rules_for_dev_portal ? concat(local.disabled_rule_group_settings_dev_portal, try(var.waf_configuration.disabled_rule_group, [])) : try(var.waf_configuration.disabled_rule_group, [])
}

#---------------------------------------
# Azure Public IP
#---------------------------------------

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.context.environment}-${var.context.product}-appgtw-pip-01"
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  sku                 = var.sku
  allocation_method   = "Static"
  tags                = local.tags
}

#---------------------------------------
# Azure Application Gateway
#---------------------------------------

resource "azurerm_application_gateway" "network" {
  name                = local.app_gateway_name
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  enable_http2        = var.enable_http2
  tags                = local.tags

  sku {
    name     = var.sku_name
    tier     = var.sku_name
    capacity = var.sku_capacity
  }

  #---------------------------------------
  # Frontend Settings
  #---------------------------------------

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.appgw_private ? ["enabled"] : []
    content {
      name                          = local.frontend_priv_ip_configuration_name
      private_ip_address_allocation = var.appgw_private ? "Static" : null
      private_ip_address            = var.appgw_private ? var.appgw_private_ip : null
      subnet_id                     = var.appgw_private ? var.subnet_id : null
    }
  }

  dynamic "frontend_port" {
    for_each = var.frontend_port_settings
    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = var.subnet_id
    #subnet_id = "subnet-appgtw"
  }

  #---------------------------------------
  # Security Settings
  #---------------------------------------

  force_firewall_policy_association = var.force_firewall_policy_association

  dynamic "waf_configuration" {
    for_each = var.sku_name == "WAF_v2" && var.waf_configuration != null ? [var.waf_configuration] : []
    content {
      enabled                  = waf_configuration.value.enabled
      file_upload_limit_mb     = waf_configuration.value.file_upload_limit_mb
      firewall_mode            = waf_configuration.value.firewall_mode
      max_request_body_size_kb = waf_configuration.value.max_request_body_size_kb
      request_body_check       = waf_configuration.value.request_body_check
      rule_set_type            = waf_configuration.value.rule_set_type
      rule_set_version         = waf_configuration.value.rule_set_version

      dynamic "disabled_rule_group" {
        for_each = local.disabled_rule_group_settings != null ? local.disabled_rule_group_settings : []
        content {
          rule_group_name = disabled_rule_group.value.rule_group_name
          rules           = disabled_rule_group.value.rules
        }
      }

      dynamic "exclusion" {
        for_each = waf_configuration.value.exclusion != null ? waf_configuration.value.exclusion : []
        content {
          match_variable          = exclusion.value.match_variable
          selector                = exclusion.value.selector
          selector_match_operator = exclusion.value.selector_match_operator
        }
      }
    }
  }

  dynamic "ssl_policy" {
    for_each = var.ssl_policy == null ? [] : ["enabled"]
    content {
      disabled_protocols   = var.ssl_policy.disabled_protocols
      policy_type          = var.ssl_policy.policy_type
      policy_name          = var.ssl_policy.policy_type == "Predefined" ? var.ssl_policy.policy_name : null
      cipher_suites        = var.ssl_policy.cipher_suites
      min_protocol_version = var.ssl_policy.min_protocol_version
    }
  }

  dynamic "ssl_profile" {
    for_each = var.ssl_profile == null ? [] : ["enabled"]

    content {
      name                             = var.ssl_profile.name
      trusted_client_certificate_names = var.ssl_profile.trusted_client_certificate_names
      verify_client_cert_issuer_dn     = var.ssl_profile.verify_client_cert_issuer_dn
      dynamic "ssl_policy" {
        for_each = var.ssl_profile.ssl_policy == null ? [] : ["enabled"]
        content {
          disabled_protocols   = var.ssl_profile.ssl_policy.disabled_protocols
          policy_type          = var.ssl_profile.ssl_policy.policy_type
          policy_name          = var.ssl_profile.ssl_policy.policy_type == "Predefined" ? var.ssl_profile.ssl_policy.policy_name : null
          cipher_suites        = var.ssl_profile.ssl_policy.cipher_suites
          min_protocol_version = var.ssl_profile.ssl_policy.min_protocol_version
        }
      }
    }
  }

  dynamic "authentication_certificate" {
    for_each = var.authentication_certificates_configs

    content {
      name = authentication_certificate.value.name
      data = authentication_certificate.value.data
    }
  }

  dynamic "trusted_client_certificate" {
    for_each = var.trusted_client_certificates_configs

    content {
      name = trusted_client_certificate.value.name
      data = trusted_client_certificate.value.data
    }
  }

  #---------------------------------------
  # Autoscaling settings
  #---------------------------------------

  dynamic "autoscale_configuration" {
    for_each = var.autoscaling_parameters != null ? ["enabled"] : []
    content {
      min_capacity = var.autoscaling_parameters.min_capacity
      max_capacity = var.autoscaling_parameters.max_capacity
    }
  }

  #---------------------------------------
  # Backend settings
  #---------------------------------------

  dynamic "backend_http_settings" {
    for_each = var.appgw_backend_http_settings
    iterator = back_http_set
    content {
      name     = back_http_set.value.name
      port     = back_http_set.value.port
      protocol = back_http_set.value.protocol

      path       = back_http_set.value.path
      probe_name = back_http_set.value.probe_name

      cookie_based_affinity               = back_http_set.value.cookie_based_affinity
      affinity_cookie_name                = back_http_set.value.affinity_cookie_name
      request_timeout                     = back_http_set.value.request_timeout
      host_name                           = back_http_set.value.host_name
      pick_host_name_from_backend_address = back_http_set.value.pick_host_name_from_backend_address
      trusted_root_certificate_names      = back_http_set.value.trusted_root_certificate_names

      dynamic "authentication_certificate" {
        for_each = back_http_set.value.authentication_certificate != null ? ["enabled"] : []
        content {
          name = back_http_set.value.authentication_certificate
        }
      }

      dynamic "connection_draining" {
        for_each = back_http_set.value.connection_draining_timeout_sec != null ? ["enabled"] : []
        content {
          enabled           = true
          drain_timeout_sec = back_http_set.value.connection_draining_timeout_sec
        }
      }
    }
  }

  dynamic "http_listener" {
    for_each = var.appgw_http_listeners
    iterator = http_listen
    content {
      name                           = http_listen.value.name
      frontend_ip_configuration_name = coalesce(http_listen.value.frontend_ip_configuration_name, var.appgw_private ? local.frontend_priv_ip_configuration_name : local.frontend_ip_configuration_name)
      frontend_port_name             = http_listen.value.frontend_port_name
      host_name                      = http_listen.value.host_name
      host_names                     = http_listen.value.host_names
      protocol                       = http_listen.value.protocol
      require_sni                    = http_listen.value.require_sni
      ssl_certificate_name           = http_listen.value.ssl_certificate_name
      ssl_profile_name               = http_listen.value.ssl_profile_name
      firewall_policy_id             = http_listen.value.firewall_policy_id
      /* # # require to configure container and blob with custom error message. 
      dynamic "custom_error_configuration" {
        for_each = http_listen.value.custom_error_configuration
        iterator = err_conf
        content {
          status_code           = err_conf.value.status_code
          custom_error_page_url = err_conf.value.custom_error_page_url
        }
      }
      */
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.appgw_backend_pools
    iterator = back_pool
    content {
      name         = back_pool.value.name
      fqdns        = back_pool.value.fqdns
      ip_addresses = back_pool.value.ip_addresses
    }
  }

  #---------------------------------------
  # Certificate settings
  #---------------------------------------

  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates_configs
    iterator = ssl_crt
    content {
      name                = ssl_crt.value.name
      data                = ssl_crt.value.data
      password            = ssl_crt.value.password
      key_vault_secret_id = ssl_crt.value.key_vault_secret_id
    }
  }

  dynamic "trusted_root_certificate" {
    for_each = var.trusted_root_certificate_configs
    iterator = ssl_crt
    content {
      name                = ssl_crt.value.name
      data                = ssl_crt.value.data == null ? try(filebase64(ssl_crt.value.file_path), null) : ssl_crt.value.data
      key_vault_secret_id = ssl_crt.value.key_vault_secret_id
    }
  }

  #---------------------------------------
  # Request Routing Rules
  #---------------------------------------

  dynamic "request_routing_rule" {
    for_each = var.appgw_routings
    iterator = routing
    content {
      name      = routing.value.name
      rule_type = routing.value.rule_type

      http_listener_name          = coalesce(routing.value.http_listener_name, routing.value.name)
      backend_address_pool_name   = routing.value.backend_address_pool_name
      backend_http_settings_name  = routing.value.backend_http_settings_name
      url_path_map_name           = routing.value.url_path_map_name
      redirect_configuration_name = routing.value.redirect_configuration_name
      rewrite_rule_set_name       = routing.value.rewrite_rule_set_name
      priority                    = coalesce(routing.value.priority, routing.key + 1)
    }
  }

  #---------------------------------------
  # Rewrite Rule Set
  #---------------------------------------

  dynamic "rewrite_rule_set" {
    for_each = var.appgw_rewrite_rule_set
    content {
      name = rewrite_rule_set.value.name

      dynamic "rewrite_rule" {
        for_each = rewrite_rule_set.value.rewrite_rules
        iterator = rule
        content {
          name          = rule.value.name
          rule_sequence = rule.value.rule_sequence

          dynamic "condition" {
            for_each = rule.value.conditions
            iterator = cond
            content {
              variable    = cond.value.variable
              pattern     = cond.value.pattern
              ignore_case = cond.value.ignore_case
              negate      = cond.value.negate
            }
          }

          dynamic "response_header_configuration" {
            for_each = rule.value.response_header_configurations == null ? [] : rule.value.response_header_configurations
            iterator = res_header
            content {
              header_name  = res_header.value.header_name
              header_value = res_header.value.header_value
            }
          }

          dynamic "request_header_configuration" {
            for_each = rule.value.request_header_configurations == null ? [] : rule.value.request_header_configurations
            iterator = req_header
            content {
              header_name  = req_header.value.header_name
              header_value = req_header.value.header_value
            }
          }

          dynamic "url" {
            for_each = rule.value.url_reroute != null ? ["enabled"] : []
            content {
              path         = rule.value.url_reroute.path
              query_string = rule.value.url_reroute.query_string
              reroute      = rule.value.url_reroute.reroute
            }
          }
        }
      }
    }
  }

  #---------------------------------------
  # Probes
  #---------------------------------------

  dynamic "probe" {
    for_each = var.appgw_probes
    content {
      name = probe.value.name

      host     = probe.value.host
      port     = probe.value.port
      interval = probe.value.interval

      path     = probe.value.path
      protocol = probe.value.protocol
      timeout  = probe.value.timeout

      pick_host_name_from_backend_http_settings = probe.value.pick_host_name_from_backend_http_settings
      unhealthy_threshold                       = probe.value.unhealthy_threshold
      minimum_servers                           = probe.value.minimum_servers
      match {
        body        = probe.value.match.body
        status_code = probe.value.match.status_code
      }
    }
  }

  #---------------------------------------
  # URL Path Mapping
  #---------------------------------------

  dynamic "url_path_map" {
    for_each = var.appgw_url_path_map
    content {
      name                                = url_path_map.value.name
      default_backend_address_pool_name   = url_path_map.value.default_backend_address_pool_name
      default_redirect_configuration_name = url_path_map.value.default_redirect_configuration_name
      default_backend_http_settings_name  = coalesce(url_path_map.value.default_backend_http_settings_name, url_path_map.value.default_backend_address_pool_name, url_path_map.value.name)

      default_rewrite_rule_set_name = url_path_map.value.default_rewrite_rule_set_name

      dynamic "path_rule" {
        for_each = url_path_map.value.path_rules
        content {
          name                       = path_rule.value.name
          backend_address_pool_name  = coalesce(path_rule.value.backend_address_pool_name, path_rule.value.name)
          backend_http_settings_name = path_rule.value.backend_http_settings_name
          rewrite_rule_set_name      = path_rule.value.rewrite_rule_set_name
          paths                      = path_rule.value.paths
        }
      }
    }
  }

  #---------------------------------------
  # Redirect configurations
  #---------------------------------------

  dynamic "redirect_configuration" {
    for_each = var.appgw_redirect_configuration
    iterator = redirect
    content {
      name                 = redirect.value.name
      redirect_type        = redirect.value.redirect_type
      target_listener_name = redirect.value.target_listener_name
      target_url           = redirect.value.target_url
      include_path         = redirect.value.include_path
      include_query_string = redirect.value.include_query_string
    }
  }

  #---------------------------------------
  # Identity management
  #---------------------------------------

  dynamic "identity" {
    for_each = var.user_assigned_identity_id != null ? ["enabled"] : []
    content {
      type         = "UserAssigned"
      identity_ids = [var.user_assigned_identity_id]
    }
  }
  depends_on = [
    resource.azurerm_public_ip.public_ip
  ]
}