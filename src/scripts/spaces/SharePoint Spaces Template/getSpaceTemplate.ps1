pushd (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)
$saveDir = (Resolve-path ".\")
Write-Host "Please enter your details"
$siteURL = Read-Host "Site Collection URL:"
$pageTitle = Read-Host "Page Title:"
$templateName = Read-Host "Template Name:"

Write-Host "Connecting to: $siteURL"
Connect-PnPOnline -Url $siteURL
Write-Host "Connected!"
 
$web = Get-PnPWeb
$sourceSite = $web.ServerRelativeUrl
$library = "Site Pages"
 
#get all pages in the site pages library
$pages = Get-PnPListItem -List $library
 
#save current homepage
$currentHomePage = Get-PnPHomePage
 
$pagesList = New-Object System.Collections.Generic.List[System.Object]
 
$pageNumber = 1
 
foreach($page in $pages){
	if($page.FileSystemObjectType -eq "File"){
		$pagePath = $page.FieldValues["FileRef"]
		$pageTitleLibrary = $page.FieldValues["Title"].ToString()
	
		#set space page as home page and save the template		
		if($pageTitleLibrary.ToLower() -eq $pageTitle.ToLower()){
			Set-PnPHomePage -RootFolderRelativeUrl ($pagePath -replace ($sourceSite+"/"), "")	
			Get-PnPProvisioningTemplate -out $($saveDir.Path + "\" + $templateName + ".xml") -Handlers PageContents					 
		}		
	}
}
 

 
#apply default default homepage
Set-PnPHomePage -RootFolderRelativeUrl $currentHomePage
 
#wait a few seconds for the template file 
Start-Sleep -Seconds 15
 
#open main xml
$mainFile = [xml][io.File]::ReadAllText($($saveDir.Path + "\" + $templateName + ".xml"))
 
#remove websettings
$mainFile.Provisioning.Templates.ProvisioningTemplate.RemoveChild($mainFile.Provisioning.Templates.ProvisioningTemplate.WebSettings)
		
$mainfile.Provisioning.Templates.ProvisioningTemplate.ClientSidePages.ClientSidePage.Title = $("##PAGENAME##").ToString()
$mainfile.Provisioning.Templates.ProvisioningTemplate.ClientSidePages.ClientSidePage.PageName = $("##PAGENAME##.aspx").ToString()

#save final tempate
$mainFile.Save($($saveDir.Path + "\" + $templateName + ".xml"))

popd