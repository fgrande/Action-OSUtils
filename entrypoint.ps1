Import-Module -Name ./utils/StringsManager.psm1
Import-Module -Name ./utils/OSZipper.psm1
Import-Module -Name ./utils/DocumentationManager.psm1

Write-Host "All Args are : $args"

Write-Host "I should manage : $args[0]"
Write-Host "Additional Param is : $args[1]"
