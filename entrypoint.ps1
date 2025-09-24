Import-Module StringsManager
Import-Module OSZipper
Import-Module DocumentationManager

$osAction = $args[0]
$osCultures = $args[1]
$osXFProject = $args[2]

Write-Host "Parameters"
Write-Host "osAction    : " $osAction
Write-Host "osCultures  : " $osCultures
Write-Host "osXFProject : " $osXFProject

switch ($osAction.ToLower())
{
    'chkstrings'
    {
        Write-Host "Start Check"
        $chkStringsResult = Show-OSStrings -onlyMissing -cultures $osCultures -baseDir $Env:GITHUB_WORKSPACE
        Write-Host "Result: " $chkStringsResult
        Write-Host "Finish Check"

        if ($chkStringsResult)
        {
            exit 1
        }
    }
    'getsources'
    {
        Write-Host "Extract Sources"
        $xfprojectLocation = "${Env:GITHUB_WORKSPACE}/${osXFProject}"
        Write-Host "Location : " $xfprojectLocation
        #format-OSSources $xfprojectLocation c:\temp\test
    }
}

exit 0