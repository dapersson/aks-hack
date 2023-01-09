# AKS hackathon - private cluster

This repo contains a step-by-step giude to setup a private AKS cluster. 

# Overview

[Picture showing what to setup]


## Prerequisites 

- Github account
- VS code with GitHub Codespaces extension
- Azure subscription 

## Getting started

### Fork and clone the repository

Log in to GitHub with your GitHub account. Fork this repo by selecting the Fork menu in the GitHub top right corner.
![fork](img/fork.png)

> **Note**<br>
> If your GitHub account is part of an organization there is a limitation that only one fork is possible in the same organization. The workaround is to clone this repo, create a new repository and then push the code from the cloned working copy similar to this:
>
>  ``` shell
>  git clone https://github.com/jonasnorlund/aks-hack
>  cd aks-hack
>  git remote set-url origin <url of your new repo>
>  git push origin master
>  ```
>

Clone the fork using git. 
```shell
git clone <your GitHub repository url>/aks-hack
cd aks-hack/private-cluster 
```


## Step-by-step guidance

Below is the step-by-step guidance. 

### Step 1 - Log in to Azure

- az login
- az account set -s [your subscription]

Need to register the following features. This is a two step process, run the following two commands we will return to this later because it can take up to 10 minutes to be finished.

- az feature register --namespace microsoft.compute --name EncryptionAtHost
- az provider register --namespace Microsoft.ContainerService

### Step 2

az group create -l westeurope -n [rg-myprefix]
check in portal

### Step 3 

Get 



az deployment group create -g [resourcegroup] -n mainDeploy -f .\main.bicep -p resourcename=[resourcename] admingroupobjectid=[objectId of AAD group]  allowedhostIp=[allowedIp for nsg] vmpwd=[8 char pwd for vm]

Login to vm
New-Item -Path $profile -Type File -Force 
notepad $profile
Set-Alias -Name k -Value kubectl