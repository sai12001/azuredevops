import sys
import json

# Main Config
template_source = "../../../../DevOps/terraform/modules/centralized_dashboards/cosmos-db/template_source"
destination_path = "../../../../DevOps/terraform/modules/centralized_dashboards/cosmos-db/dashboard_templates"
f = open(f'{template_source}/main_dashboard.json')
main_dashboard = json.load(f)
f.close()

f = open(f'{template_source}/docdb_ru_consumption.json')
ru_consumption = json.load(f)
f.close()

f = open(f'{template_source}/docdb_data_usage.json')
docdb_data_usage = json.load(f)
f.close()

f = open(f'{template_source}/docdb_index_usage.json')
index_data_usage = json.load(f)
f.close()

f = open(f'{template_source}/docdb_total_requests.json')
total_requests = json.load(f)
f.close()

f = open(f'{template_source}/docdb_server_side_latency.json')
server_side_latency = json.load(f)
f.close()

f = open(f'{template_source}/docdb_4xx.json')
http_4xx = json.load(f)
f.close()

f = open(f'{template_source}/docdb_5xx.json')
http_5xx = json.load(f)
f.close()

def generate_overides(resource_displaynames):
    overrides = []

    for resource in resource_displaynames:
        overide_template = {
          "matcher": {
            "id": "byFrameRefID",
          }
        }
        overide_template["matcher"]["options"] = resource
        properties = {
                "id": "displayName",
                "value": resource
                }
        prop = []
        prop.append(properties)
        overide_template["properties"] = prop

        overrides.append(overide_template)
    
    return overrides

def generate_overides_with_lables(resource_displaynames):
    overrides = []

    for resource in resource_displaynames:
        overide_template = {
          "matcher": {
            "id": "byFrameRefID",
          }
        }
        overide_template["matcher"]["options"] = resource
        properties = {
                "id": "displayName",
                "value": resource + '| ${dimension}'
                }
        prop = []
        prop.append(properties)
        overide_template["properties"] = prop

        overrides.append(overide_template)
    
    return overrides

def generate_ru_consumption(resource_list):
  target_array = []
  for resource in resource_list:
    target_template = {
      "azureMonitor": {
        "aggregation": "Maximum",
        "allowedTimeGrainsMs": [
          60000,
          300000,
          3600000,
          86400000
        ],
        "dimensionFilters": [],
        "metricName": "NormalizedRUConsumption",
        "metricNamespace": "microsoft.documentdb/databaseaccounts",
        "timeGrain": "auto"
      },
      "datasource": {
        "type": "grafana-azure-monitor-datasource"
      },
      "queryType": "Azure Monitor",
      "refId": "A"
    }
    
    target_template["azureMonitor"]["resourceGroup"] = resource["resource_group_name"]
    target_template["azureMonitor"]["resourceName"] = resource["resource_name"]
    target_template["refId"]= resource["display_name"]
    target_template["datasource"]["uid"] = "${AzureDataSourceID}"
    target_template["subscription"]= "${SUBSCRIPTION}"

    target_array.append(target_template)
  overides = generate_overides(resource_displaynames)
  ru_consumption["fieldConfig"]["overrides"] = overides
  ru_consumption["targets"] = target_array
  return ru_consumption

def generate_data_usage(resource_list):
  target_array = []
  for resource in resource_list:
    target_template = {
        "azureMonitor": {
          "aggregation": "Total",
          "allowedTimeGrainsMs": [
            300000
          ],
          "dimensionFilters": [],
          "metricName": "DataUsage",
          "metricNamespace": "microsoft.documentdb/databaseaccounts",
          "timeGrain": "auto"
        },
        "datasource": {
          "type": "grafana-azure-monitor-datasource"
        },
        "queryType": "Azure Monitor",
        "refId": "A"
      }
    
    target_template["azureMonitor"]["resourceGroup"] = resource["resource_group_name"]
    target_template["azureMonitor"]["resourceName"] = resource["resource_name"]
    target_template["refId"]= resource["display_name"]
    target_template["datasource"]["uid"] = "${AzureDataSourceID}"
    target_template["subscription"]= "${SUBSCRIPTION}"
    # target_template["datasource"]["uid"] = "6RiW4V4Vz"
    # target_template["subscription"]= "75d2fa14-67cf-41aa-9717-875861f4f0d7"

    target_array.append(target_template)
  overides = generate_overides(resource_displaynames)
  docdb_data_usage["fieldConfig"]["overrides"] = overides
  docdb_data_usage["targets"] = target_array
  return docdb_data_usage

def generate_index_usage(resource_list):
  target_array = []
  for resource in resource_list:
    target_template = {
      "azureMonitor": {
        "aggregation": "Total",
        "allowedTimeGrainsMs": [
          300000
        ],
        "dimensionFilters": [],
        "metricName": "IndexUsage",
        "metricNamespace": "microsoft.documentdb/databaseaccounts",
        "timeGrain": "auto"
      },
      "datasource": {
        "type": "grafana-azure-monitor-datasource"
      },
      "queryType": "Azure Monitor"
    }
    
    target_template["azureMonitor"]["resourceGroup"] = resource["resource_group_name"]
    target_template["azureMonitor"]["resourceName"] = resource["resource_name"]
    target_template["refId"]= resource["display_name"]
    target_template["datasource"]["uid"] = "${AzureDataSourceID}"
    target_template["subscription"]= "${SUBSCRIPTION}"

    target_array.append(target_template)
  overides = generate_overides(resource_displaynames)
  index_data_usage["fieldConfig"]["overrides"] = overides
  index_data_usage["targets"] = target_array
  return index_data_usage

def generate_total_requests(resource_list):
  target_array = []
  for resource in resource_list:
    target_template = {
      "azureMonitor": {
        "aggregation": "Count",
        "allowedTimeGrainsMs": [
          300000,
          86400000
        ],
        "dimensionFilters": [],
        "metricName": "TotalRequests",
        "metricNamespace": "microsoft.documentdb/databaseaccounts",
        "timeGrain": "auto"
      },
      "datasource": {
        "type": "grafana-azure-monitor-datasource"
      },
      "queryType": "Azure Monitor"
    }
    
    target_template["azureMonitor"]["resourceGroup"] = resource["resource_group_name"]
    target_template["azureMonitor"]["resourceName"] = resource["resource_name"]
    target_template["refId"]= resource["display_name"]
    target_template["datasource"]["uid"] = "${AzureDataSourceID}"
    target_template["subscription"]= "${SUBSCRIPTION}"

    target_array.append(target_template)
  overides = generate_overides(resource_displaynames)
  total_requests["fieldConfig"]["overrides"] = overides
  total_requests["targets"] = target_array
  return total_requests

def generate_server_side_latency(resource_list):
  target_array = []
  for resource in resource_list:
    target_template = {
      "azureMonitor": {
        "aggregation": "Average",
        "allowedTimeGrainsMs": [
          60000,
          300000,
          900000,
          1800000,
          3600000,
          21600000,
          43200000,
          86400000
        ],
        "dimensionFilters": [],
        "metricName": "ServerSideLatency",
        "metricNamespace": "microsoft.documentdb/databaseaccounts",
        "timeGrain": "auto"
      },
      "datasource": {
        "type": "grafana-azure-monitor-datasource"
      },
      "queryType": "Azure Monitor"
    }
    
    target_template["azureMonitor"]["resourceGroup"] = resource["resource_group_name"]
    target_template["azureMonitor"]["resourceName"] = resource["resource_name"]
    target_template["refId"]= resource["display_name"]
    target_template["datasource"]["uid"] = "${AzureDataSourceID}"
    target_template["subscription"]= "${SUBSCRIPTION}"

    target_array.append(target_template)
  overides = generate_overides(resource_displaynames)
  server_side_latency["fieldConfig"]["overrides"] = overides
  server_side_latency["targets"] = target_array
  return server_side_latency

def generate_4xx(resource_list):
  target_array = []
  for resource in resource_list:
    target_template = {
          "azureMonitor": {
            "aggregation": "Count",
            "allowedTimeGrainsMs": [
              60000,
              300000,
              3600000,
              86400000
            ],
            "dimensionFilters": [
              {
                "dimension": "StatusCode",
                "filters": [
                  "4"
                ],
                "operator": "sw"
              }
            ],
            "metricName": "TotalRequests",
            "metricNamespace": "microsoft.documentdb/databaseaccounts",
            "timeGrain": "auto"
          },
          "datasource": {
            "type": "grafana-azure-monitor-datasource"
          },
          "queryType": "Azure Monitor"
        }
    
    target_template["azureMonitor"]["resourceGroup"] = resource["resource_group_name"]
    target_template["azureMonitor"]["resourceName"] = resource["resource_name"]
    target_template["refId"]= resource["display_name"]
    target_template["datasource"]["uid"] = "${AzureDataSourceID}"
    target_template["subscription"]= "${SUBSCRIPTION}"

    target_array.append(target_template)
  overides = generate_overides_with_lables(resource_displaynames)
  http_4xx["fieldConfig"]["overrides"] = overides
  http_4xx["targets"] = target_array
  return http_4xx

def generate_5xx(resource_list):
  target_array = []
  for resource in resource_list:
    target_template = {
          "azureMonitor": {
            "aggregation": "Count",
            "allowedTimeGrainsMs": [
              60000,
              300000,
              3600000,
              86400000
            ],
            "dimensionFilters": [
              {
                "dimension": "StatusCode",
                "filters": [
                  "5"
                ],
                "operator": "sw"
              }
            ],
            "metricName": "TotalRequests",
            "metricNamespace": "microsoft.documentdb/databaseaccounts",
            "timeGrain": "auto"
          },
          "datasource": {
            "type": "grafana-azure-monitor-datasource"
          },
          "queryType": "Azure Monitor"
        }
    
    target_template["azureMonitor"]["resourceGroup"] = resource["resource_group_name"]
    target_template["azureMonitor"]["resourceName"] = resource["resource_name"]
    target_template["refId"]= resource["display_name"]
    target_template["datasource"]["uid"] = "${AzureDataSourceID}"
    target_template["subscription"]= "${SUBSCRIPTION}"

    target_array.append(target_template)
  overides = generate_overides_with_lables(resource_displaynames)
  http_5xx["fieldConfig"]["overrides"] = overides
  http_5xx["targets"] = target_array
  return http_5xx

def generate_full_dashboard(resource_list):
  panels = []
  panels.append(generate_ru_consumption(resource_list))
  panels.append(generate_4xx(resource_list))
  panels.append(generate_5xx(resource_list))
  panels.append(generate_data_usage(resource_list))
  panels.append(generate_index_usage(resource_list))
  panels.append(generate_total_requests(resource_list))
  panels.append(generate_server_side_latency(resource_list))

  main_dashboard["panels"] = panels
  return main_dashboard

def get_resource_names():
  app_name_list = [x["display_name"] for x in cosmos_dbs ]
  resource_list = []
  for resource in cosmos_dbs:
    data = {
      "display_name": resource["display_name"],
      "resource_group_name": resource["resource_group"],
      "resource_name": resource["full_name"]
    }
    resource_list.append(data)

  return resource_list,app_name_list


environment = sys.argv[1]
cosmos_dbs = json.loads(sys.argv[2])

resource_list,resource_displaynames = get_resource_names()
main_dashboard = generate_full_dashboard(resource_list)
output_filename = f"cent_docdb_dashboard"

with open(f'{destination_path}/{output_filename}.json', 'w') as out:
  json.dump(main_dashboard, out)
