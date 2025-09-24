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
    "chkstrings"
    {
        $chkStringsResult = Show-OSStrings -onlyMissing -cultures it-IT,en-US,fr-FR
        Write-Host $chkStringsResult
    }
}

Write-Host $Env:PSModulePath