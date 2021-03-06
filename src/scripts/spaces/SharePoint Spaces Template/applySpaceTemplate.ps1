pushd (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)
$dir = (Resolve-path ".\")
Write-Host "Please enter your details"
$siteURL = Read-Host "Site Collection URL:"
$pageTitle = Read-Host "Page Title:"
$templateName = Read-Host "Template Name:"

Write-Host "Connecting to: $siteURL"
Connect-PnPOnline -Url $siteURL
Write-Host "Connected!"
 
((Get-Content -path $($dir.Path + "\" + $templateName + ".xml") -Raw) -replace '##PAGENAME##', $pageTitle) | Set-Content -Path 'temp.xml'
 
Apply-PnPProvisioningTemplate -path temp.xml
Remove-Item -Path 'temp.xml'
 
popd