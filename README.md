# aks-hack

az deployment group create -g [resourcegroup] -n mainDeploy -f .\main.bicep -p admingroupobjectid=[objectId of AAD group] resourcename=[resourcename] allowedhostIp=[allowedIp for nsg] vmpwd=[8 char pwd for vm]

Login to vm
New-Item -Path $profile -Type File -Force 
notepad $profile
Set-Alias -Name k -Value kubectl