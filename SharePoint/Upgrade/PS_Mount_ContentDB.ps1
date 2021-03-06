############################################################################################################################################
# Script that allows to execute the cmdlet Mount-SPContentDatabase against a specific Content Database in a SharePoint farm
# Required parameters: 
#   -> $sServerInstance: Name of the server where content databases are living.
#   -> $sDatabaseName: Name of the Content DB to be tested
#   -> $sWebAppUrl: Web Application Url used to execute Mount-SPConentDatabase
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Function that allows to execute Mount-SPContentDatabase for a specific Webg Application in a SharePoint Farm
function Execute-MountContentDatabase
{  
    param ($sServerInstance,$sDatabaseName,$sWebAppUrl)
    try
    {
        Mount-SPContentDatabase –Name $sDatabaseName -DataBaseServer $sServerInstance -WebApplication $sWebAppUrl
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}
#Required parameters
$sServerInstance="<SQL_ServerInstance>"
$sDatabaseName="<ContentDB_Name>"
$sWebAppUrl="http://<WebApp_Url>/"
Start-SPAssignment –Global
Execute-MountContentDatabase -sServerInstance $sServerInstance -sDatabaseName $sDatabaseName -sWebAppUrl $sWebAppUrl
Stop-SPAssignment –Global

Remove-PsSnapin Microsoft.SharePoint.PowerShell