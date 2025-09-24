Import-Module StringsManager
Import-Module OSZipper
Import-Module DocumentationManager

$osAction = $args[0]
$osCultures = $args[1]

Write-Host "Parameters"
Write-Host "osAction   : " $osAction
Write-Host "osCultures : " $osCultures

switch ($osAction.ToLower())
{
    'chkstrings'
    {
        Write-Host "Start Check"
        $chkStringsResult = Show-OSStrings -onlyMissing -cultures $osCultures -baseDir $Env:GITHUB_WORKSPACE
        Write-Host $chkStringsResult
        Write-Host "Finish Check"

        if ($chkStringsResult)
        {
            exit 1
        }
    }
}

exit 0