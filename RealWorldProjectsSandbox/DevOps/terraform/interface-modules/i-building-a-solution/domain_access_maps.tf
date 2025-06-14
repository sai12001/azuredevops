locals {
  domain_access_maps = {
    "account"   = ["bet", "racing", "console", "sport"]
    "racing"    = ["account", "bet"]
    "bet"       = ["account", "console"]
    "promotion" = ["acount", "bet"]
    "sport"     = ["account", "bet"]
    "infra"     = []
    "whatever"  = ["account", "bet"]
    "core"      = []
    "console"   = ["account", "bet"]
    "utilities" = []
  }
}
