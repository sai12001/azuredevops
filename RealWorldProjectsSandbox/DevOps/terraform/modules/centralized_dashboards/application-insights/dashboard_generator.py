import sys
import json

template_source = "../../../../DevOps/terraform/modules/centralized_dashboards/application-insights/template_source"
destination_path = "../../../../DevOps/terraform/modules/centralized_dashboards/application-insights/dashboard_templates"

f = open(f'{template_source}/main_dashboard.json')
main_dashboard = json.load(f)
f.close()

f = open(f'{template_source}/CAI_Dep_Call_Fails.json')
dep_call_fail_template = json.load(f)
f.close()

f = open(f'{template_source}/CAI_Failed_Requests.json')
failed_requests_template = json.load(f)
f.close()

f = open(f'{template_source}/CAI_Exceptions.json')
exceptions_template = json.load(f)
f.close()

f = open(f'{template_source}/CAI_Server_Exceptions.json')
server_exceptions_template = json.load(f)
f.close()

f = open(f'{template_source}/CAI_Server_Requests.json')
server_requests_template = json.load(f)
f.close()

f = open(f'{template_source}/CAI_Response_Time.json')
server_response_time_template = json.load(f)
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

def generate_depend_call_fail_panel(resource_list):
  target_array = []
  for resource in resource_list:
    target_template = {
      "azureMonitor": {
        "aggregation": "Count",
        "alias": "{{ ResourceName }}",
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
        "metricName": "dependencies/failed",
        "metricNamespace": "microsoft.insights/components",
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
  dep_call_fail_template["fieldConfig"]["overrides"] = overides
  dep_call_fail_template["targets"] = target_array
  
  return dep_call_fail_template

def generate_failed_request_targets(resource_list):
  target_array = []
  for resource in resource_list:
    target_template = {
      "azureMonitor": {
        "aggregation": "Count",
        "alias": "{{ ResourceName }}",
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
        "metricName": "requests/failed",
        "metricNamespace": "microsoft.insights/components",
        "timeGrain": "auto"
      },
      "datasource": {
        "type": "grafana-azure-monitor-datasource",
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
  failed_requests_template["fieldConfig"]["overrides"] = overides
  failed_requests_template["targets"] = target_array
  
  return failed_requests_template

def generate_exceptions_targets(resource_list):
  target_array = []
  for resource in resource_list:
    target_template = {
      "azureMonitor": {
        "aggregation": "Count",
        "alias": "{{ ResourceName }}",
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
        "metricName": "exceptions/count",
        "metricNamespace": "microsoft.insights/components",
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
  exceptions_template["fieldConfig"]["overrides"] = overides
  exceptions_template["targets"] = target_array

  return exceptions_template

def generate_server_exceptions_targets(resource_list):
  target_array = []
  for resource in resource_list:
    target_template = {
      "azureMonitor": {
        "aggregation": "Count",
        "alias": "{{ ResourceName }}",
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
        "metricName": "exceptions/server",
        "metricNamespace": "microsoft.insights/components",
        "timeGrain": "auto"
      },
      "datasource": {
        "type": "grafana-azure-monitor-datasource",
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
  server_exceptions_template["fieldConfig"]["overrides"] = overides
  server_exceptions_template["targets"] = target_array

  return server_exceptions_template

def generate_server_requests_targets(resource_list):
  target_array = []
  for resource in resource_list:
    target_template = {
      "azureMonitor": {
        "aggregation": "Count",
        "alias": "{{ ResourceName }}",
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
        "metricName": "requests/count",
        "metricNamespace": "microsoft.insights/components",
        "timeGrain": "auto"
      },
      "datasource": {
        "type": "grafana-azure-monitor-datasource"
      },
      "queryType": "Azure Monitor",
    }
    target_template["azureMonitor"]["resourceGroup"] = resource["resource_group_name"]
    target_template["azureMonitor"]["resourceName"] = resource["resource_name"]
    target_template["refId"]= resource["display_name"]
    target_template["datasource"]["uid"] = "${AzureDataSourceID}"
    target_template["subscription"]= "${SUBSCRIPTION}"
    target_array.append(target_template)
  
  overides = generate_overides(resource_displaynames)
  server_requests_template["fieldConfig"]["overrides"] = overides
  server_requests_template["targets"] = target_array

  return server_requests_template

def generate_server_response_time_targets(resource_list):
  target_array = []
  for resource in resource_list:
    target_template = {
      "azureMonitor": {
        "aggregation": "Average",
        "alias": "{{ ResourceName }}",
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
        "metricName": "requests/duration",
        "metricNamespace": "microsoft.insights/components",
        "timeGrain": "auto"
      },
      "datasource": {
        "type": "grafana-azure-monitor-datasource",
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
  server_response_time_template["fieldConfig"]["overrides"] = overides
  server_response_time_template["targets"] = target_array

  return server_response_time_template

def generate_full_dashboard(resource_list):
  panels = []

  panels.append(generate_depend_call_fail_panel(resource_list))
  panels.append(generate_failed_request_targets(resource_list))
  panels.append(generate_exceptions_targets(resource_list))
  panels.append(generate_server_exceptions_targets(resource_list))
  panels.append(generate_server_requests_targets(resource_list))
  panels.append(generate_server_response_time_targets(resource_list))

  main_dashboard["panels"] = panels
  return main_dashboard

def get_resource_names(app_insights):
  app_insight_name_list = [x["display_name"] for x in app_insights ]
  resource_list = []
  for resource in app_insights:
    data = {
      "display_name": resource["display_name"],
      "resource_group_name": resource["resource_group"],
      "resource_name":resource["full_name"]
    }
    resource_list.append(data)

  return resource_list,app_insight_name_list

environment = sys.argv[1]
app_insights = json.loads(sys.argv[2])

resource_list,resource_displaynames = get_resource_names(app_insights)
generated_main_dashboard = generate_full_dashboard(resource_list)
output_filename = f"cent_ai_dashboard"

with open(f'{destination_path}/{output_filename}.json', 'w') as out:
  json.dump(generated_main_dashboard, out)