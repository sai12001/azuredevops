locals {
  cosmo_db_metrics = {
    RUConsumption_database = {
      description        = "Max RU consumption percentage per minute filtered by filtered by Database Name"
      metric_namespace   = "microsoft.documentdb/databaseaccounts"
      metric_name        = "NormalizedRUConsumption"
      aggregation        = "Maximum"
      operator           = "GreaterThan"
      threshold          = 75
      dimension_name     = "DatabaseName"
      dimension_operator = "Include"
      dimension_values   = ["*"]
    }

    RUConsumption_Collection = {
      description        = "Max RU consumption percentage per minute filtered by Collection Name"
      metric_namespace   = "microsoft.documentdb/databaseaccounts"
      metric_name        = "NormalizedRUConsumption"
      aggregation        = "Maximum"
      operator           = "GreaterThan"
      threshold          = 75
      dimension_name     = "CollectionName"
      dimension_operator = "Include"
      dimension_values   = ["*"]
    }

    RUConsumption_account = {
      description      = "Max RU consumption percentage per minute"
      metric_namespace = "microsoft.documentdb/databaseaccounts"
      metric_name      = "NormalizedRUConsumption"
      aggregation      = "Maximum"
      operator         = "GreaterThan"
      threshold        = 75
      dimension_name   = "No Dimensions"
    }

    ServerSideLatency_database = {
      description        = "Average Server Side Latency filtered by filtered by Database Name"
      metric_namespace   = "microsoft.documentdb/databaseaccounts"
      metric_name        = "ServerSideLatency"
      aggregation        = "Average"
      operator           = "GreaterThan"
      threshold          = 1000
      dimension_name     = "DatabaseName"
      dimension_operator = "Include"
      dimension_values   = ["*"]
    }

    ServerSideLatency_Collection = {
      description        = "Average Server Side Latency filtered by Collection Name"
      metric_namespace   = "microsoft.documentdb/databaseaccounts"
      metric_name        = "ServerSideLatency"
      aggregation        = "Average"
      operator           = "GreaterThan"
      threshold          = 1000
      dimension_name     = "CollectionName"
      dimension_operator = "Include"
      dimension_values   = ["*"]
    }

    ServerSideLatency_account = {
      description      = "Average Server Side Latency"
      metric_namespace = "microsoft.documentdb/databaseaccounts"
      metric_name      = "ServerSideLatency"
      aggregation      = "Average"
      operator         = "GreaterThan"
      threshold        = 1000
      dimension_name   = "No Dimensions"
    }

    TotalRequests_database = {
      description        = "Count Total Requests filtered by filtered by Database Name"
      metric_namespace   = "microsoft.documentdb/databaseaccounts"
      metric_name        = "TotalRequests"
      aggregation        = "Count"
      operator           = "GreaterThan"
      threshold          = 150
      dimension_name     = "DatabaseName"
      dimension_operator = "Include"
      dimension_values   = ["*"]
    }

    TotalRequests_Collection = {
      description        = "Count Total Requests filtered by Collection Name"
      metric_namespace   = "microsoft.documentdb/databaseaccounts"
      metric_name        = "TotalRequests"
      aggregation        = "Count"
      operator           = "GreaterThan"
      threshold          = 150
      dimension_name     = "CollectionName"
      dimension_operator = "Include"
      dimension_values   = ["*"]
    }

    TotalRequests_account = {
      description      = "Count Total Requests"
      metric_namespace = "microsoft.documentdb/databaseaccounts"
      metric_name      = "TotalRequests"
      aggregation      = "Count"
      operator         = "GreaterThan"
      threshold        = 150
      dimension_name   = "No Dimensions"
    }

  }

  eventhub_metric_alerts = {

    IncomingMessages = {
      description      = "Incoming Messages for Microsoft.EventHub"
      metric_namespace = "microsoft.eventhub/namespaces"
      metric_name      = "IncomingMessages"
      aggregation      = "Total"
      operator         = "GreaterThan"
      threshold        = 100
      dimension_name   = "No Dimensions"
    }

    IncomingRequests = {
      description      = "Incoming Requests for Microsoft.EventHub"
      metric_namespace = "microsoft.eventhub/namespaces"
      metric_name      = "IncomingRequests"
      aggregation      = "Total"
      operator         = "GreaterThan"
      threshold        = 100
      dimension_name   = "No Dimensions"
    }

    NamespaceCpuUsage = {
      description      = "CPU usage metric for Premium SKU namespaces"
      metric_namespace = "microsoft.eventhub/namespaces"
      metric_name      = "NamespaceCpuUsage"
      aggregation      = "Maximum"
      operator         = "GreaterThan"
      threshold        = 75
      dimension_name   = "No Dimensions"
    }

    NamespaceMemoryUsage = {
      description      = "CPU usage metric for Premium SKU namespaces"
      metric_namespace = "microsoft.eventhub/namespaces"
      metric_name      = "NamespaceMemoryUsage"
      aggregation      = "Maximum"
      operator         = "GreaterThan"
      threshold        = 75
      dimension_name   = "No Dimensions"
    }

    OutgoingMessages = {
      description      = "Outgoing Bytes for Microsoft.EventHub."
      metric_namespace = "microsoft.eventhub/namespaces"
      metric_name      = "OutgoingMessages"
      aggregation      = "Total"
      operator         = "GreaterThan"
      threshold        = 100
      dimension_name   = "No Dimensions"
    }

    Size = {
      description      = "Size of an EventHub in Bytes."
      metric_namespace = "microsoft.eventhub/namespaces"
      metric_name      = "Size"
      aggregation      = "Average"
      operator         = "GreaterThan"
      threshold        = 1000
      dimension_name   = "No Dimensions"
    }

    ThrottledRequests = {
      description      = "Throttled Requests for Microsoft.EventHub"
      metric_namespace = "microsoft.eventhub/namespaces"
      metric_name      = "Size"
      aggregation      = "Average"
      operator         = "GreaterThan"
      threshold        = 100
      dimension_name   = "No Dimensions"
    }
  }
}
