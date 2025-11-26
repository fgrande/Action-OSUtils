Import-Module StringsManager
Import-Module OSZipper
Import-Module DocumentationManager

$osAction = $args[0]
$osCultures = $args[1]
$osXFProject = $args[2]
$osSourcesTempDir = $args[3]
$osNamespacePrefix = $args[4]
$osAssemblyName = $args[5]
$osVersion = $args[6]
$snippetBaseDir = $args[7]
$snippetZipFile = $args[8]

Write-Host "Parameters"
Write-Host "osAction          : " $osAction
Write-Host "osCultures        : " $osCultures
Write-Host "osXFProject       : " $osXFProject
Write-Host "osSourcesTempDir  : " $osSourcesTempDir
Write-Host "osNamespacePrefix : " $osNamespacePrefix
Write-Host "osAssemblyName    : " $osAssemblyName
Write-Host "osVersion         : " $osVersion
Write-Host "snippetBaseDir    : " $snippetBaseDir
Write-Host "snippetZipFile    : " $snippetZipFile

switch ($osAction.ToLower())
{
    'chkstrings'
    {
        #Write-Host "Start Check"

        $chkStringsResult = Show-OSStrings -onlyMissing -cultures $osCultures -baseDir $Env:GITHUB_WORKSPACE
        
        #Write-Host "Finish Check"

        if ($chkStringsResult)
        {
            Write-Host "Result: " $chkStringsResult
            exit 1
        }

        Write-Host "OK ! No missing Strings !"
    }
    'getsources'
    {
        Write-Host "Extract Sources"
        $xfprojectLocation = "${Env:GITHUB_WORKSPACE}/${osXFProject}"
        Write-Host "Location : " $xfprojectLocation

        $sourcesLocation = "${Env:GITHUB_WORKSPACE}/${osSourcesTempDir}"

        Format-OSSources -sourceXFProject $xfprojectLocation -destPath $sourcesLocation -wsNamespacePrefix $osNamespacePrefix -wsAssemblyName $osAssemblyName
    }
    'extractbr'
    {
        Write-Host "Extract BRules"
        $xfprojectLocation = "${Env:GITHUB_WORKSPACE}/${osXFProject}"
        Write-Host "Location : " $xfprojectLocation

        $sourcesLocation = "${Env:GITHUB_WORKSPACE}/${osSourcesTempDir}"

        Split-BRules -sourceXFProject $xfprojectLocation -destPath $sourcesLocation -osVersion $osVersion -zipped
    }
    'buildsnippets'
    {
        Write-Host "Build Snippets"
        $baseDir = "${Env:GITHUB_WORKSPACE}"

        Build-Snippets -baseDir $baseDir -zipFileName $snippetZipFile
    }
    default
    {
        Write-Host "Unknown Action : $osAction"
        exit 1
    }
}

exit 0