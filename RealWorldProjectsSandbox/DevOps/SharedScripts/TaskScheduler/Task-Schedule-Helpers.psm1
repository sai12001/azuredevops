function CreateWeeklyTriggers {
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [DayOfWeek[]] $WeekDays,
        [Parameter(Mandatory)]
        [DateTime] $StartTimeMachineTime,
        [Parameter(Mandatory)]
        [int] $RepetionIntervalInMinutes,
        [Parameter(Mandatory)]
        [int] $RepetitionDurationInHours
    )    
    $TriggerHelper = New-ScheduledTaskTrigger -Once -AT "00:00:00" -RepetitionInterval (New-TimeSpan -Minutes $RepetionIntervalInMinutes) `
    -RepetitionDuration (New-TimeSpan -Hours $RepetitionDurationInHours -Minutes 0)
    $Trigger = New-ScheduledTaskTrigger -Weekly -At $StartTimeMachineTime -DaysOfWeek $WeekDays -WeeksInterval 1
    $Trigger.Repetition = $TriggerHelper.Repetition

    return $Trigger
}

function CreateDailyTriggers {
    param (
        [Parameter(Mandatory)]
        [DateTime] $StartTimeMachineTime,
        [Parameter(Mandatory)]
        [int] $RepetionIntervalInMinutes,
        [Parameter(Mandatory)]
        [int] $RepetitionDurationInHours
    )       
    $TriggerHelper = New-ScheduledTaskTrigger -Once -AT "01:00:00" -RepetitionInterval (New-TimeSpan -Minutes $RepetionIntervalInMinutes) `
    -RepetitionDuration (New-TimeSpan -Hours $RepetitionDurationInHours -Minutes 0)
    $Trigger = New-ScheduledTaskTrigger -Daily -At $StartTimeMachineTime -DaysInterval 1
    $Trigger.Repetition = $TriggerHelper.Repetition

    return $Trigger
}