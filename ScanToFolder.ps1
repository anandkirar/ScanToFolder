#Folder creation

$folderPath = "C:\Scans"

if (-Not (Test-Path -Path $folderPath)) {
    New-Item -Path $folderPath -ItemType Directory
    Write-Host "Folder 'Scans' created at $folderPath"
} else {
    Write-Host "Folder 'Scans' already exists at $folderPath"
}

#Creating Scans user

$username = "Scans"
$password = ConvertTo-SecureString "Scans@123" -AsPlainText -Force

$userExists = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
$LocalgroupExists = net localgroup Administrators | findstr /i "Scans"

if ($userExists) 
{
    $userExists | Set-LocalUser -Password $password
    Write-Host "Password for user '$username' has been updated."
    if (-not $LocalgroupExists) {
        Add-LocalGroupMember -Group "Administrators" -Member $username
        Write-Host "User '$username' has been added to the Administrators group."
	}
} 
else 
{
    New-LocalUser -Name $username -Password $password
    Write-Host "User '$username' has been created with the specified password."
    Add-LocalGroupMember -Group "Users" -Member $username
    Add-LocalGroupMember -Group "Administrators" -Member $username
    Write-Host "User '$username' has been added to both the Users and Administrators groups."
}

Set-LocalUser -Name "Scans" -PasswordNeverExpires $true

#Folder permissions

$folderPath = "C:\Scans"

$shareName = "Scans"

if($shareName)
{
Remove-SmbShare -Name $shareName -Confirm:$false
}

New-SmbShare -Name $shareName -Path $folderPath -FullAccess "Scans","Everyone"

$acl = Get-Acl $folderPath

$scansRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Scans", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")

$everyoneRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")

$acl.SetAccessRule($scansRule)
$acl.SetAccessRule($everyoneRule)
Set-Acl $folderPath $acl





