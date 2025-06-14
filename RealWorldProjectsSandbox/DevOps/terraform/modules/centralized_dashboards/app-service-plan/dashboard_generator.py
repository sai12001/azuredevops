import sys
import json

# Main Config
template_source = "../../../../DevOps/terraform/modules/centralized_dashboards/app-service-plan/template_source"
destination_path = "../../../../DevOps/terraform/modules/centralized_dashboards/app-service-plan/dashboard_templates"
# destination_path = "./dashboard_templates"

f = open(f'{template_source}/main_dashboard.json')
main_dashboard = json.load(f)
f.close()

f = open(f'{template_source}/CASP_cpu_guage.json')
cpu_template = json.load(f)
f.close()

f = open(f'{template_source}/CASP_memory_guage.json')
memory_template = json.load(f)
f.close()

f = open(f'{template_source}/CASP_DiskQueueLength.json')
DiskQueueLength = json.load(f)
f.close()

f = open(f'{template_source}/CASP_BytesReceived.json')
BytesReceived = json.load(f)
f.close()

f = open(f'{template_source}/CASP_BytesSent.json')
BytesSent = json.load(f)
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

def generate_cpu(resource_list):
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
          "metricName": "CpuPercentage",
          "metricNamespace": "microsoft.web/serverfarms",
          "resourceGroup": "dev-rg-ng-bet-shared-eau",
          "resourceName": "dev-asp-ng-bet-datatools-eau",
          "timeGrain": "auto",
          "top": ""
        },
        "datasource": {
          "type": "grafana-azure-monitor-datasource",
          "uid": "${AzureDataSourceID}"
        },
        "queryType": "Azure Monitor",
        "refId": "A",
        "subscription": "${SUBSCRIPTION}"
      }
    target_template["azureMonitor"]["resourceGroup"] = resource["resource_group_name"]
    target_template["azureMonitor"]["resourceName"] = resource["resource_name"]
    target_template["refId"]= resource["asp_name"]

    target_array.append(target_template)
  overides = generate_overides(resource_displaynames)
  print(overides)
  print("############################################")
  cpu_template["fieldConfig"]["overrides"] = overides
  cpu_template["targets"] = target_array
  return cpu_template

def generate_memory(resource_list):
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
          "metricName": "MemoryPercentage",
          "metricNamespace": "microsoft.web/serverfarms",
          "timeGrain": "auto",
          "top": ""
        },
        "datasource": {
          "type": "grafana-azure-monitor-datasource",
          "uid": "${AzureDataSourceID}"
        },
        "queryType": "Azure Monitor",
        "refId": "A",
        "subscription": "${SUBSCRIPTION}"
      }
    target_template["azureMonitor"]["resourceGroup"] = resource["resource_group_name"]
    target_template["azureMonitor"]["resourceName"] = resource["resource_name"]
    target_template["refId"]= resource["asp_name"]

    target_array.append(target_template)
  overides = generate_overides(resource_displaynames)
  memory_template["fieldConfig"]["overrides"] = overides
  memory_template["targets"] = target_array
  return memory_template

def generate_dql(resource_list):
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
          "metricName": "DiskQueueLength",
          "metricNamespace": "microsoft.web/serverfarms",
          "timeGrain": "auto",
          "top": ""
        },
        "datasource": {
          "type": "grafana-azure-monitor-datasource",
          "uid": "${AzureDataSourceID}"
        },
        "queryType": "Azure Monitor",
        "refId": "A",
        "subscription": "${SUBSCRIPTION}"
      }

    target_template["azureMonitor"]["resourceGroup"] = resource["resource_group_name"]
    target_template["azureMonitor"]["resourceName"] = resource["resource_name"]
    target_template["refId"]= resource["asp_name"]

    target_array.append(target_template)
  overides = generate_overides(resource_displaynames)
  DiskQueueLength["fieldConfig"]["overrides"] = overides
  DiskQueueLength["targets"] = target_array
  return DiskQueueLength

def generate_datain(resource_list):
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
          "metricName": "BytesReceived",
          "metricNamespace": "microsoft.web/serverfarms",
          "timeGrain": "auto",
          "top": ""
        },
        "datasource": {
          "type": "grafana-azure-monitor-datasource",
          "uid": "${AzureDataSourceID}"
        },
        "queryType": "Azure Monitor",
        "refId": "A",
        "subscription": "${SUBSCRIPTION}"
      }

    target_template["azureMonitor"]["resourceGroup"] = resource["resource_group_name"]
    target_template["azureMonitor"]["resourceName"] = resource["resource_name"]
    target_template["refId"]= resource["asp_name"]

    target_array.append(target_template)
  overides = generate_overides(resource_displaynames)
  BytesReceived["fieldConfig"]["overrides"] = overides
  BytesReceived["targets"] = target_array
  return BytesReceived

def generate_dataout(resource_list):
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
          "metricName": "BytesSent",
          "metricNamespace": "microsoft.web/serverfarms",
          "timeGrain": "auto",
          "top": ""
        },
        "datasource": {
          "type": "grafana-azure-monitor-datasource",
          "uid": "${AzureDataSourceID}"
        },
        "hide": False,
        "queryType": "Azure Monitor",
        "refId": "D",
        "subscription": "${SUBSCRIPTION}"
      }
    target_template["azureMonitor"]["resourceGroup"] = resource["resource_group_name"]
    target_template["azureMonitor"]["resourceName"] = resource["resource_name"]
    target_template["refId"]= resource["asp_name"]

    target_array.append(target_template)
  overides = generate_overides(resource_displaynames)
  BytesSent["fieldConfig"]["overrides"] = overides
  BytesSent["targets"] = target_array
  return BytesSent

def generate_full_dashboard(resource_list):
  panels = []
  panels.append(generate_cpu(resource_list))
  panels.append(generate_memory(resource_list))
  panels.append(generate_dql(resource_list))
  panels.append(generate_datain(resource_list))
  panels.append(generate_dataout(resource_list))

  main_dashboard["panels"] = panels
  return main_dashboard

def get_resource_names(app_service_plans):
  app_name_list = [x["abbr_name"] for x in app_service_plans ]
  resource_list = []
  for asp in app_service_plans:
    data = {
      "asp_name": asp["abbr_name"],
      "resource_group_name": asp["resource_group"],
      "resource_name":asp["full_name"]
    }
    resource_list.append(data)

  return resource_list,app_name_list


environment = sys.argv[1]
app_service_plans = json.loads(sys.argv[2])
resource_list,resource_displaynames = get_resource_names(app_service_plans)
main_dashboard = generate_full_dashboard(resource_list)
output_filename = f"cent_asp_dashboard"

with open(f'{destination_path}/{output_filename}.json', 'w') as out:
  json.dump(main_dashboard, out)
