iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
choco install azure-cli -y -f
choco install kubernetes-cli -y -f
choco install kubens -y
choco install kubectx -y
choco install azure-kubelogin -y
choco install git -y
choco install openlens -y --ignore-checksums

