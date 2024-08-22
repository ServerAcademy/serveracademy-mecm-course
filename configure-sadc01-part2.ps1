# WARNING! This script should ONLY be run in dev / lab environments.
# This script is designed to be run inside of a lab you setup in at ServerAcademy.com
# Run this script AFTER you run part 1 and have rebooted the server

# NOTE: Make sure you have logged into your server as a DOMAIN administrator and not localAdmin

# Run the following command to change your script execution policy so you can run this script:

# Set-ExecutionPolicy -ExecutionPolicy Unrestricted

# Install the DHCP Server role
Install-WindowsFeature -Name DHCP -IncludeManagementTools

# Configure DHCP scope
$ScopeName = "Clients"
$StartRange = "10.0.2.100"
$EndRange = "10.0.2.200"
$SubnetMask = "255.255.255.0"
$DefaultGateway = "10.0.2.1"
$DefaultGateway = "10.0.2.1"
$DnsServer = "10.0.2.10"
Add-DhcpServerv4Scope -Name $ScopeName -StartRange $StartRange -EndRange $EndRange -SubnetMask $SubnetMask -State Active
Set-DhcpServerv4OptionValue -ScopeId 10.0.2.0 -Router $DefaultGateway
Set-DhcpServerv4OptionValue -ScopeId 10.0.2.0 -DnsServer $DnsServer

# Define the domain name
$DomainName = "serveracademy.com"
$DomainDN = "DC=serveracademy,DC=com"

# Create Organizational Units
$OUs = @(
    "OU=ServerAcademy,$DomainDN",
    "OU=Workstations,OU=ServerAcademy,$DomainDN",
    "OU=Groups,OU=ServerAcademy,$DomainDN",
    "OU=Users,OU=ServerAcademy,$DomainDN",
    "OU=Admins,OU=ServerAcademy,$DomainDN",
    "OU=Member Servers,OU=ServerAcademy,$DomainDN",
    "OU=Service Accounts,OU=ServerAcademy,$DomainDN"
)

foreach ($OU in $OUs) {
    New-ADOrganizationalUnit -Name ($OU.Split(",")[0].Split("=")[1]) -Path ($OU.Substring($OU.IndexOf(",") + 1))
}

# Create Users in the Users OU
$Users = @(
    @{Name="Paul Hill"; SamAccountName="Paul.Hill"; Path="OU=Users,OU=ServerAcademy,$DomainDN"},
    @{Name="Robert Hill"; SamAccountName="Robert.Hill"; Path="OU=Users,OU=ServerAcademy,$DomainDN"},
    @{Name="Test User"; SamAccountName="Test.User"; Path="OU=Users,OU=ServerAcademy,$DomainDN"}
)

foreach ($User in $Users) {
    New-ADUser -Name $User.Name -SamAccountName $User.SamAccountName -UserPrincipalName "$($User.SamAccountName)@$DomainName" `
               -Path $User.Path -AccountPassword (ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force) -Enabled $true
}

# Create Users in the Admins OU
$AdminUsers = @(
    @{Name="Paul Hill (Admin)"; SamAccountName="Paul.Hill-Admin"; Path="OU=Admins,OU=ServerAcademy,$DomainDN"},
    @{Name="Robert Hill (Admin)"; SamAccountName="Robert.Hill-Admin"; Path="OU=Admins,OU=ServerAcademy,$DomainDN"},
    @{Name="Test User (Admin)"; SamAccountName="Test.User-Admin"; Path="OU=Admins,OU=ServerAcademy,$DomainDN"}
)

foreach ($AdminUser in $AdminUsers) {
    New-ADUser -Name $AdminUser.Name -SamAccountName $AdminUser.SamAccountName -UserPrincipalName "$($AdminUser.SamAccountName)@$DomainName" `
               -Path $AdminUser.Path -AccountPassword (ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force) -Enabled $true

    # Add Admin Users to Domain Admins group
    Add-ADGroupMember -Identity "Domain Admins" -Members $AdminUser.SamAccountName
}
