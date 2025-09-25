Import-Module StringsManager
Import-Module OSZipper
Import-Module DocumentationManager

$osAction = $args[0]
$osCultures = $args[1]
$osXFProject = $args[2]
$osSourcesTempDir = $args[3]
$osNamespacePrefix = $args[4]
$osAssemblyName = $args[5]

Write-Host "Parameters"
Write-Host "osAction          : " $osAction
Write-Host "osCultures        : " $osCultures
Write-Host "osXFProject       : " $osXFProject
Write-Host "osSourcesTempDir  : " $osSourcesTempDir
Write-Host "osNamespacePrefix : " $osNamespacePrefix
Write-Host "osAssemblyName    : " $osAssemblyName

switch ($osAction.ToLower())
{
    'chkstrings'
    {
        Write-Host "Start Check"

        $chkStringsResult = Show-OSStrings -onlyMissing -cultures $osCultures -baseDir $Env:GITHUB_WORKSPACE

        if ($chkStringsResult)
        {
            Write-Host "Result: " $chkStringsResult
        }
        else
        {
            Write-Host "OK ! No missing Strings !"
        }
        
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

        Format-OSSources -sourceXFProject $xfprojectLocation -destPath $sourcesLocation -wsNamespacePrefix $osNamespacePrefix -wsAssemblyName $osAssemblyName
    }
}

exit 0