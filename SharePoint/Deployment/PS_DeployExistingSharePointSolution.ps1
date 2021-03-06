############################################################################################################################################
# This script allows to deploy an existing SharePoint solution to a specific Web Application
# Required Parameters:
#   ->$sSolutionName: SharePoint Solution Name.
#   ->$sWebAppUrl: Web Application Url where the SharePoint solution is going to be deployed.
#   ->$sFeatureName: Name of the feature to be enabled.
#   ->$sSiteCollecionUrl: Site Collection Url where the feature is going to be enabled. 
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

$sSolutionName="<Solution_Name>.wsp"
$sFeatureName="<Feature_Name>"
$sWebAppUrl="http://<Web_Application_URL/"
$sSiteCollectionUrl="http://<Site_Collection_URL>"
$sSolutionPath=$sCurrentDir + "\"+$sSolutionName 

#This function allows to wait until the Timer Job execution finishes
function WaitForJobToFinish([string]$sSolutionName)
{ 
    try
    {
        $JobName = "*solution-deployment*$sSolutionName*"
        $job = Get-SPTimerJob | ?{ $_.Name -like $JobName }
        if ($job -eq $null) 
        {
            Write-Host 'Timer job not found'
        }
        else
        {
            $JobFullName = $job.Name
            Write-Host -NoNewLine "Waiting for the Timer Job $JobFullName"
        
            while ((Get-SPTimerJob $JobFullName) -ne $null) 
            {
                Write-Host -NoNewLine .
                Start-Sleep -Seconds 2
            }
            Write-Host  "Waiting Time for the Time Job just finished ..."
        }
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }    
}

#Function that deploys the solution to the specific web application
function DeploySolution([string] $sSolutionName, [string] $sWebAppUrl)
{
    try
    {
        $spFarm = Get-SPFarm
        $spSolutions = $spFarm.Solutions
        $spSolutionToDeploy=$null 
        foreach ($spSolution in $spSolutions)
        {
            if ($spSolution.Name -eq $sSolutionName)
            {
                $spSolutionToDeploy = $spSolution            
                break
            }
        }    
        Write-Host 'Deploying the farm solution $sSolutionName'   
    
        if (  $spSolutionToDeploy.ContainsWebApplicationResource ) {
            Install-SPSolution –identity $sSolutionName –GACDeployment -WebApplication $sWebAppUrl     
        }
        else {
            Install-SPSolution –identity $sSolutionName –GACDeployment -Force
        }
        WaitForJobToFinish 
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }      
}

DeploySolution -sSolutionName $sSolutionName -sWebAppUrl $sWebAppUrl

#Enabling - Disabling the feature
Write-Host 'Disabling the feature $sFeatureName'
Disable-SPFeature –identity $sFeatureName -Url $sSiteCollectionUrl -Confirm:$false
Write-Host 'Enabling the feature $sFeatureName'
Enable-SPFeature –identity $sFeatureName -Url $sSiteCollectionUrl

Remove-PSSnapin Microsoft.SharePoint.PowerShell