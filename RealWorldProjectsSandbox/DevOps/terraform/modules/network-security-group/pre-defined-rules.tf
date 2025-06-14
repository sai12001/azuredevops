locals {
  # [direction, access, protocol, source_port_range, destination_port_range, description]"
  # The following info are in the submodules: source_address_prefix, destination_address_prefix
  rules = {
    OfficeIp = {
      description                  = "office_ip"
      direction                    = "Inbound",
      access                       = "Allow",
      protocol                     = "Tcp",
      source_address_prefix        = null
      source_address_prefixes      = ["139.130.32.10/32"],
      source_port_range            = "*",
      destination_port_range       = "*",
      destination_address_prefixes = null,
      destination_address_prefix   = "*"
      priority                     = 501
    },
    Rdp = {
      description                  = "rdp_access"
      direction                    = "Inbound",
      access                       = "Allow",
      protocol                     = "Tcp",
      source_address_prefix        = null
      source_address_prefixes      = null, # TBD
      source_port_range            = "*",
      destination_port_range       = "3389",
      destination_address_prefixes = null,
      destination_address_prefix   = "*"
      priority                     = 502
    }
    Http = {
      description                  = "http_access"
      direction                    = "Inbound",
      access                       = "Allow",
      protocol                     = "Tcp",
      source_address_prefix        = null
      source_address_prefixes      = null, # TBD
      source_port_range            = "*",
      destination_port_range       = "80",
      destination_address_prefixes = null,
      destination_address_prefix   = "*"
      priority                     = 503
    }
    Https = {
      description                  = "https_access"
      direction                    = "Inbound",
      access                       = "Allow",
      protocol                     = "Tcp",
      source_address_prefix        = null
      source_address_prefixes      = null, # TBD
      source_port_range            = "*",
      destination_port_range       = "443",
      destination_address_prefixes = null,
      destination_address_prefix   = "*"
      priority                     = 504
    }
    Ssh = {
      description                  = "ssh_access"
      direction                    = "Inbound",
      access                       = "Allow",
      protocol                     = "Tcp",
      source_address_prefix        = null
      source_address_prefixes      = null, # TBD
      source_port_range            = "*",
      destination_port_range       = "22",
      destination_address_prefixes = null,
      destination_address_prefix   = "*"
      priority                     = 505
    }
    MsSql = {
      description                  = "sql_server"
      direction                    = "Inbound",
      access                       = "Allow",
      protocol                     = "Tcp",
      source_address_prefix        = null
      source_address_prefixes      = null, # TBD
      source_port_range            = "*",
      destination_port_range       = "1433",
      destination_address_prefixes = null,
      destination_address_prefix   = "*"
      priority                     = 506
    }
    PostgreSQL = {
      description                  = "postgresql_server"
      direction                    = "Inbound",
      access                       = "Allow",
      protocol                     = "Tcp",
      source_address_prefix        = null
      source_address_prefixes      = null, # TBD
      source_port_range            = "*",
      destination_port_range       = "5432",
      destination_address_prefixes = null,
      destination_address_prefix   = "*"
      priority                     = 507
    }
    RabbitMq = {
      description                  = "rabbitmq_server"
      direction                    = "Inbound",
      access                       = "Allow",
      protocol                     = "Tcp",
      source_address_prefix        = null
      source_address_prefixes      = null, # TBD
      source_port_range            = "*",
      destination_port_range       = "5672,5672,2083",
      destination_address_prefixes = null,
      destination_address_prefix   = "*"
      priority                     = 508
    }
  }
}
