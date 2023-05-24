# Create the MDM key if it doesn't exist
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion" -Name "MDM" -Force | Out-Null

# Enable automatic MDM enrollment using default Azure AD credentials
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM" -Name "EnableAutomaticMDMEnrollmentWithAADCredentials" -Value 1 -PropertyType "DWord" -Force | Out-Null

# Set registry path and variables
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM"
New-Item -Path $registryPath

$Name = "AutoEnrollMDM"
$Name2 = "UseAADCredentialType"
$value = "1"

# Create registry keys - Out-Null just disables any output from the console
new-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
new-ItemProperty -Path $registryPath -Name $name2 -Value $value -PropertyType DWORD -Force | Out-Null
gpupdate /force

#define reg key variables + registrations URLs
$key = 'SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\*'
$keyinfo = Get-Item "HKLM:\$key"
$url = $keyinfo.name
$url = $url.Split("\")[-1]
$path = "HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\$url"

# Set enrollment URLs
New-ItemProperty -LiteralPath $path -Name 'MdmEnrollmentUrl' -Value 'https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath $path  -Name 'MdmTermsOfUseUrl' -Value 'https://portal.manage.microsoft.com/TermsofUse.aspx' -PropertyType String -Force -ea SilentlyContinue;
New-ItemProperty -LiteralPath $path -Name 'MdmComplianceUrl' -Value 'https://portal.manage.microsoft.com/?portalAction=Compliance' -PropertyType String -Force -ea SilentlyContinue;

C:\Windows\system32\deviceenroller.exe /c /AutoEnrollMDM