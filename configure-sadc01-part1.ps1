# WARNING! This script should ONLY be run in dev / lab environments.
# This script is designed to be run inside of a lab you setup in at ServerAcademy.com
# This script should run after you complete the Server Academy (SADC01) Domain Controller OS installation. After this script is complete,
# run part 2 to finish the DC configuration.

# Set Variables
$DomainName = "serveracademy.com"
$SafeModePassword = "password123"  # Replace with a secure password

# Install AD Domain Services
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

# Promote the server to a Domain Controller with a new forest
Install-ADDSForest -DomainName $DomainName -ForestMode "WinThreshold" -DomainMode "WinThreshold" `
                   -DatabasePath "C:\Windows\NTDS" -SysvolPath "C:\Windows\SYSVOL" `
                   -LogPath "C:\Windows\NTDS" -InstallDNS -SafeModeAdministratorPassword (ConvertTo-SecureString $SafeModePassword -AsPlainText -Force) `
                   -Force -NoRebootOnCompletion

# Reboot the server to complete promotion
Restart-Computer -Force