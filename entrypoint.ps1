Import-Module StringsManager
Import-Module OSZipper
Import-Module DocumentationManager

$osAction = $args[0]
$osProjectDir = $args[1]

Write-Host "Parameters"
Write-Host "osAction     : " $osAction
Write-Host "osProjectDir : " $osProjectDir

switch ($osAction.ToLower())
{
    'chkstrings'
    {
        Write-Host "Start Check"
        $chkStringsResult = Show-OSStrings -onlyMissing -cultures it-IT,en-US,fr-FR -baseDir $Env:GITHUB_WORKSPACE
        Write-Host $chkStringsResult
        Write-Host "Finish Check"
    }
}
