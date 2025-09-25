Import-Module StringsManager
Import-Module OSZipper
Import-Module DocumentationManager

$osAction = $args[0]
$osCultures = $args[1]
$osXFProject = $args[2]
$osSourcesDir = $args[3]

Write-Host "Parameters"
Write-Host "osAction         : " $osAction
Write-Host "osCultures       : " $osCultures
Write-Host "osXFProject      : " $osXFProject
Write-Host "osSourcesTempDir : " $osSourcesTempDir

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

        $sourcesLocation = "${Env:GITHUB_WORKSPACE}/${osSourcesTempDir}"

        format-OSSources $xfprojectLocation $sourcesLocation

        Get-ChildItem $sourcesLocation
    }
}

exit 0