workflow VM-Start-Stop-Scheduler
{
    Param(
        [Parameter (Mandatory= $true)]
        [string] $subscriptionid,

        [Parameter (Mandatory= $false)]
        [string] $tagkey = "VMStartStopScheduler",

        [Parameter (Mandatory= $false)]
        [string] $tagvalue = "schedule_1",

        [Parameter (Mandatory= $false)]
        [string] $action = "stop",

        [Parameter (Mandatory= $false)]
        [string] $vmnamelistcomma = "null"
    )

    # Default Variables ########################
    # $subscriptionid = "75d2fa14-67cf-41aa-9717-875861f4f0d7"
    $VMObjs = @()
    $vmnamelist = $vmnamelistcomma.split(",") 
    # ##########################################

    # Ensures you do not inherit an AzContext in your runbook
    Disable-AzContextAutosave -Scope Process

    # Connect to Azure with system-assigned managed identity
    Connect-AzAccount -Identity

    # set and store context
    $AzureContext = Set-AzContext –subscriptionid $subscriptionid

    $tagVMs = Get-AzVM -DefaultProfile $AzureContext | Where-Object {$_.Tags[$tagkey] -eq $tagvalue} | Select-Object Name,ResourceGroupName
    $VMObjs += $tagVMs
    
    if ($vmnamelist[0] -ne "null") {
        ForEach -Parallel ($l_vm in $workflow:vmnamelist){
            $tmp_vm = Get-AzVM -DefaultProfile $AzureContext -Name $l_vm | Select-Object Name,ResourceGroupName
            $workflow:VMObjs += $tmp_vm
        }
    }

    Write-Output ("############################")
    Write-Output ("# List OF Virtual Machines #")
    Write-Output ("############################")
    Write-Output ($VMObjs.Name)
    Write-Output ("############################")

    ForEach -Parallel ($s_vm in $VMObjs)
    {
        # Write-Output ("Getting Virtual Machine: $($s_vm.Name) in Resource Group: $($s_vm.ResourceGroupName)")
        # $vm = Get-AzVM -ResourceGroupNam $s_vm.ResourceGroupName -Name $s_vm.Name -DefaultProfile $AzureContext   
        # Write-Output ($vm)
        
        if ($action -eq "start") {
            Write-Output ("Starting Virtual Machine: $($s_vm.Name) in Resource Group: $($s_vm.ResourceGroupName)")
            Start-AzVM -ResourceGroupNam $s_vm.ResourceGroupName -Name $s_vm.Name -DefaultProfile $AzureContext
        }
        elseif ($action -eq "stop") {
            Write-Output ("Stopping Virtual Machine: $($s_vm.Name) in Resource Group: $($s_vm.ResourceGroupName)")
            Stop-AzVM -ResourceGroupNam $s_vm.ResourceGroupName -Name $s_vm.Name -DefaultProfile $AzureContext -Force
        }
    }

}