locals {
  today     = timestamp()
  start_day = formatdate("YYYY-MM-DD", timeadd(local.today, "24h"))
}
resource "azurerm_automation_schedule" "schedule" {
  for_each                = var.schedule_list
  name                    = each.key
  resource_group_name     = var.resource_group.name
  automation_account_name = each.value.automation_account_name
  frequency               = each.value.frequency
  interval                = each.value.frequency == "OneTime" ? null : each.value.interval
  timezone                = each.value.timezone
  start_time              = "${local.start_day}T${each.value.start_time}"
  description             = each.value.description
  week_days               = each.value.frequency == "Week" ? each.value.week_days : null
  month_days              = each.value.frequency == "Month" ? each.value.month_days : null

  lifecycle {
    ignore_changes = [
      start_time
    ]
  }

  depends_on = [
    azurerm_automation_runbook.runbook
  ]
}

resource "azurerm_automation_job_schedule" "job_schedule" {
  for_each                = var.job_schedule_list
  resource_group_name     = var.resource_group.name
  automation_account_name = each.value.automation_account_name
  schedule_name           = each.value.schedule_name
  runbook_name            = each.value.runbook_name
  
  parameters = each.value.parameters

  depends_on = [
    azurerm_automation_schedule.schedule
  ]
}