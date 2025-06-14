$ConfigurationsPath_UAT = "$PSScriptRoot/configuration.json"
# $ConfigurationsPath_Prod = "$PSScriptRoot/configuration.uat.json"

Import-Module "$PSScriptRoot/Task-Schedule-Helpers.psm1"
Import-Module "$PSScriptRoot/Convert-Cron-Exp.psm1"
$DeploymentFolder = "C:\Jobs\"


$Configurations = Get-Content $ConfigurationsPath_UAT | ConvertFrom-Json


$Configurations.ScheduledTaskMappings | ForEach-Object {

    $TaskConfig = $_
    #Basic Task Properties
    $TaskName = $TaskConfig.Resulting_Name
    $TaskDescription = $TaskConfig.Description

    $Enabled = [bool]$TaskConfig.Enabled

    #Some task configuration
    $Principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $Settings = New-ScheduledTaskSettingsSet
    $Settings.ExecutionTimeLimit = "PT30M"

    # Task Action
    $Action = New-ScheduledTaskAction -Execute "$DeploymentFolder$($TaskConfig.TaragetScript)"

    # Triggers
    $Triggers = @()

    $TriggerConfigurations = $TaskConfig.CronSchedules

    $TriggerConfigurations | ForEach-Object {
        $TriggerConfiguration = $_
        $RepetitionMinutes = $TriggerConfiguration.RepetitionMinutes
        $RepetionLastForHours = $TriggerConfiguration.RepetionLastForHours
        $ConvertedTime = ConvertFrom-PodeCronExpression $TriggerConfiguration.CronTab
        $StartTimeHour = format-number $($ConvertedTime.hour.values).tostring()
        $StartTimeMinute = format-number $($ConvertedTime.minute.values).tostring()
        $DaysOfWeek = $ConvertedTime.dayofweek.values
        $StartTimeMachineTime = datetime-construct $StartTimeHour $StartTimeMinute
        if($DaysOfWeek.Count -gt 0){
            $Trigger1 = CreateWeeklyTriggers -WeekDays (Get-DaysOfWeek $DaysOfWeek) -StartTimeMachineTime $StartTimeMachineTime -RepetionIntervalInMinutes $RepetitionMinutes -RepetitionDurationInHours $RepetionLastForHours
        }else{
            $Trigger1 = CreateDailyTriggers -StartTime $StartTimeMachineTime -RepetionIntervalInMinutes $RepetitionMinutes -RepetitionDurationInHours $RepetionLastForHours
        }
        $Triggers += $Trigger1
    }
  
    $Task = New-ScheduledTask -Action $Action -Trigger $Triggers -Settings $Settings -Principal $Principal
    $Task
    $ExistingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction Ignore

    if (-NOT($ExistingTask)) {
        Write-Host "Schedule Job[$TaskName] Does not Exist, will create a new job with ...."
        Register-ScheduledTask -TaskName $TaskName -InputObject $Task 

        if(!$Enabled){
            #Disabled by default
            Disable-ScheduledTask $TaskName
        }
    }
    else {
        Write-Host "Schedule Job[$TaskName] Presents, Update it with {} {}...."
        Set-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Triggers -Settings $Settings -Principal $Principal

        if(!$Enabled){
            #Disabled by default
            Disable-ScheduledTask $TaskName
        }

    }

    # make sure the schedule task lock get released
    Start-Sleep -Seconds 5


}





