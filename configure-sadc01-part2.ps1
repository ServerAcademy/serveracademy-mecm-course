# WARNING! This script should ONLY be run in dev / lab environments.
# This script is designed to be run inside of a lab you setup in at ServerAcademy.com
# Run this script AFTER you run part 1 and have rebooted the server

# Install the DHCP Server role
Install-WindowsFeature -Name DHCP -IncludeManagementTools

# Configure DHCP scope
Add-DhcpServerv4Scope -Name "Clients" -StartRange 10.0.2.100 -EndRange 10.0.2.200 -SubnetMask 255.255.255.0 -State Active

# Create Organizational Units
$OUs = @(
    "OU=ServerAcademy,$DomainName",
    "OU=Workstations,OU=ServerAcademy,$DomainName",
    "OU=Groups,OU=ServerAcademy,$DomainName",
    "OU=Users,OU=ServerAcademy,$DomainName",
    "OU=Admins,OU=ServerAcademy,$DomainName",
    "OU=Member Servers,OU=ServerAcademy,$DomainName",
    "OU=Service Accounts,OU=ServerAcademy,$DomainName"
)

foreach ($OU in $OUs) {
    New-ADOrganizationalUnit -Name $OU.Split("=")[1] -Path $OU.Substring($OU.IndexOf(",") + 1)
}

# Create Users in the Users OU
$Users = @(
    @{Name="Paul Hill"; SamAccountName="Paul.Hill"; Path="OU=Users,OU=ServerAcademy,$DomainName"},
    @{Name="Robert Hill"; SamAccountName="Robert.Hill"; Path="OU=Users,OU=ServerAcademy,$DomainName"},
    @{Name="Test User"; SamAccountName="Test.User"; Path="OU=Users,OU=ServerAcademy,$DomainName"}
)

foreach ($User in $Users) {
    New-ADUser -Name $User.Name -SamAccountName $User.SamAccountName -UserPrincipalName "$($User.SamAccountName)@$DomainName" `
               -Path $User.Path -AccountPassword (ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force) -Enabled $true
}

# Create Users in the Admins OU
$AdminUsers = @(
    @{Name="Paul Hill (Admin)"; SamAccountName="Paul.Hill.Admin"; Path="OU=Admins,OU=ServerAcademy,$DomainName"},
    @{Name="Robert Hill (Admin)"; SamAccountName="Robert.Hill.Admin"; Path="OU=Admins,OU=ServerAcademy,$DomainName"},
    @{Name="Test User (Admin)"; SamAccountName="Test.User.Admin"; Path="OU=Admins,OU=ServerAcademy,$DomainName"}
)

foreach ($AdminUser in $AdminUsers) {
    New-ADUser -Name $AdminUser.Name -SamAccountName $AdminUser.SamAccountName -UserPrincipalName "$($AdminUser.SamAccountName)@$DomainName" `
               -Path $AdminUser.Path -AccountPassword (ConvertTo-SecureString "P@ssw0rd!" -AsPlainText -Force) -Enabled $true

    # Add Admin Users to Domain Admins group
    Add-ADGroupMember -Identity "Domain Admins" -Members $AdminUser.SamAccountName
}