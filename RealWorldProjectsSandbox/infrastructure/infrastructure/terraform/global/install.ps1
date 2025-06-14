Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Setup services
choco install pwsh -y
choco install azure-cli -y
choco install visualstudio2019buildtools -y
choco install az.powershell -y
choco install dotnet-sdk -y
choco install python -y
choco install nodejs -y
choco install docker-engine -y
choco install jmeter -y
choco install k6 -y
choco install git -y
choco install dotnetcore-sdk
choco install dotnet-6.0-sdk
choco install netfx-4.7.2-devpack
choco install netfx-4.5.2-devpack


dotnet tool install -g microsoft.sqlpackage
Install-Module -Name SqlServer

########
# CREATE VM IMAGEE
# Use SysPrep to Sanitize VM first before run following 
Set-Location C:\Windows\System32\Sysprep
./sysprep.exe /oobe /generalize /mode:vm /shutdown

$rg = "rg-core-infra-agents"
$vm_name = "temp-vm-image-builder"
$date_yyyyMMdd = Get-Date -Format "yyyyMMdd.HH.mm"
$image_name = "prd-img-agent-vm-win-$date_yyyyMMdd"

az vm deallocate -g $rg -n $vm_name
az vm generalize -g $rg -n $vm_name
az image create -g $rg -n $image_name --source $vm_name --hyper-v-generation v2

######### 
#########
# NO LONGER USE FOLLOWING AS WE DIRECTLY HOCK AZURE DEVOPS TO VMSS
# FOLLOW THIS LINK https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops
########
########


# # setup agent
# Set-Location $HOME\Downloads
# Invoke-WebRequest https://vstsagentpackage.azureedge.net/agent/2.210.1/vsts-agent-win-x64-2.210.1.zip -OutFile ./vsts-agent-win-x64-2.210.1.zip

# Set-Location C:\
# mkdir agent ; 
# Set-Location agent
# Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$HOME\Downloads\vsts-agent-win-x64-2.210.1.zip", "$PWD")
# .\config.cmd --agent $env:COMPUTERNAME --runasservice --work '_work' --url 'https://dev.azure.com/BlackStream/' --projectname 'NextGen' --pool private-agents-win
# .\run.cmd

