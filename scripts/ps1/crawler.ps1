# Import SharePoint Online Module
Import-Module SharePointPnPPowerShellOnline -WarningAction SilentlyContinue

# Variables
$SiteURL = ""
$Credential = Get-Credential

# Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Credentials $Credential

# Get All Webs from the Site collection
$Webs = Get-PnPSubWebs -Recurse

# Iterate through each web
ForEach($web in $Webs)
{
    Write-host -f Green "Working on Site:"$web.Url
}
