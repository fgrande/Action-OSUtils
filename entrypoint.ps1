Import-Module StringsManager
Import-Module OSZipper
Import-Module DocumentationManager

$osAction = $args[0]

Write-Host "Parameters"
Write-Host "osAction : " $osAction

switch ($osAction.ToLower())
{
    "chkstrings"
    {
        $chkStringsResult = Show-OSStrings -onlyMissing -cultures it-IT,en-US,fr-FR
        Write-Host $chkStringsResult
    }
}

Write-Host $Env:PSModulePath