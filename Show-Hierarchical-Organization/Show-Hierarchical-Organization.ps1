try 
{ 
    $var = Get-AzureADTenantDetail >$NULL
} 
catch [Microsoft.Open.Azure.AD.CommonLibrary.AadNeedAuthenticationException] 
{ 
    Write-Host "You're not connected => opening a new Azure AD Session" -ForegroundColor Red 
    Connect-AzureAD >$NULL
}

if ($args.length -gt 0)
{
  $userUPN = $args[0]
}
else
{
    write-host "Rendering hierarchical organization for one user." -ForegroundColor Cyan
    write-host 
	$userUPN = Read-Host "Please enter user's email  (eg: 'firstname.lastname@company.com') "
}
if([string]::IsNullOrEmpty($userUPN))
{
    Write-Host "No input information -> Exit." -ForegroundColor Red
    Write-Host
    break
}
else
{
    try
    {
        write-host "Get informations for user : " -NoNewline -foreground Yellow; Write-Host $userUPN 
        $user = Get-AzureADUser -ObjectId $userUPN
        $userObjectId = $user.ObjectId
    }
    catch
    {
    }
}

if ($userObjectId -eq $NULL)
{
    Write-Host
    write-Host "> Script Stopped : user/email not found." -ForegroundColor Red
    Exit
}

## DISPLAY REQUEST USER INFORMATIONS
write-host 
write-host "User Display Name : " -NoNewline; Write-Host $user.DisplayName -ForegroundColor Green
#write-host "User Object Id    :"$userObjectId
write-host 

## READ INFORMATIONS ABOVE AND UNDER
$lstUserDirectReport = Get-AzureADUserDirectReport -ObjectId $userObjectId | Sort-Object DisplayName
$userManager = Get-AzureADUserManager -ObjectId $userObjectId

if ($userManager.ObjectId -eq $userObjectId)
{
    $userManagerDisplayName = "(Himself)"
}
else {
    $userManagerDisplayName = $userManager.DisplayName 
}

if ($userManagerDisplayName -eq $NULL)
{
    $userManagerDisplayName = "(Undefined)"
}

## RENDER HIERARCHICAL TREE
Write-Host "Organization: " -ForegroundColor Yellow
Write-Host
Write-host $userManagerDisplayName
Write-host " | " 
Write-host " |--> " 
Write-host "      "$user.DisplayName -ForegroundColor Green
Write-host "       | " 
$totalDirectReports = $lstUserDirectReport.Count
if ($totalDirectReports -gt 0)
{
    Write-host "       |-->  Direct Reports ($totalDirectReports)"
    Write-host 
    foreach ($lstUser in $lstUserDirectReport)
    {
        if ($lstUser.DisplayName -ne $user.DisplayName)
        {
            Write-host "            "$lstUser.DisplayName
        }
    }
}
else {
    Write-host "       |-->  (no one)"
}
Write-Host