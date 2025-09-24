<#

.Synopsis
Check all Strings files to build a recap of translations.

.Description
Check all Strings files to build a recap of translations.

.Parameter onlyMissing
If specified, only strings with at least a missing translation will be reported.

.Parameter cultures
Comma-Separated cultures to look for 

.Example
PS> Show-OSStrings -onlyMissing -cultures it-IT,en-US -baseDir c:\works\project

#>

function Show-OSStrings 
{
	Param(
	  [switch] $onlyMissing,
	  [string] $cultures,
	  [string] $baseDir
	)
	
	$result = @()

	$culturesArr = $cultures.Split(',')

	Write-Host 'Cultures is a ' $culturesArr.GetType()
	Write-Host 'Cultures length is  ' $culturesArr.Length
	
	[int32] $cultureCounter = $culturesArr ? $culturesArr.Length : 0
	$culturesLower = $culturesArr ? $culturesArr.ToLower() : @()

	if ($cultureCounter -eq 0)
	{
		$onlyMissing = $false
	}

	Write-Host "Only Missing : " $onlyMissing

	#Write-Output "Base Dir: " $baseDir

	$dirToCheck = $baseDir
	if ([string]::IsNullOrEmpty($dirToCheck))
	{
		$dirToCheck = Get-Location
	}
	
	Write-Output "Checking Dir: " $dirToCheck
	Write-Output "Cultures to Check : " $cultures

	foreach ($file in Get-ChildItem -Path $dirToCheck -Recurse *.xml | Where-Object { Select-String "stringResource" $_ -Quiet })
	{
		#Write-Output "Found File $($file.FullName)"
			
		$dbString = New-Object -TypeName PSObject

		if ($cultureCounter -gt 0)
		{
			foreach ($c in $culturesArr)
			{
				$dbString | Add-Member -Name $c -MemberType Noteproperty -Value ""
			}
		}
			
		$mainContent = [xml](Get-Content -Path $file.FullName)
		[xml]$cdata = $mainContent.XFProjectFile.content."#cdata-section"
	
		$dbString | Add-Member -Name "Name" -MemberType Noteproperty -Value $cdata.stringResource.name
		$dbString | Add-Member -Name "WorkSpace" -MemberType Noteproperty -Value $cdata.stringResource.workspace
		$dbString | Add-Member -Name "MaintenanceUnit" -MemberType Noteproperty -Value $cdata.stringResource.maintenanceUnit

		[int32] $foundCultureCounter = 0
		
		foreach ($v in $cdata.stringResource.textValuesByCulture.textValueByCulture)
		{
			$cultureName = $v.culture
			
			if ($culturesLower.Contains($cultureName.ToLower()) -or $cultureCounter -eq 0)
			{
				$dbString | Add-Member -Force -Name $cultureName -MemberType Noteproperty -Value $v.textValue 
			
				# Current culture is one of the observed and its value is not empty
				if ($culturesLower.Contains($cultureName.ToLower()) -and $v.textValue)
				{
					$foundCultureCounter = $foundCultureCounter + 1
				}
			}
		}
	
		#$dbString | Add-Member -Name "CulturesCount" -MemberType Noteproperty -Value $cultureCounter
		#$dbString | Add-Member -Name "CulturesFound" -MemberType Noteproperty -Value $foundCultureCounter
		
		if (($onlyMissing -and ($foundCultureCounter -ne $cultureCounter)) -or !$onlyMissing)
		{
			$result += $dbString
		}
	}
	
	return $result
}


function Export-OSStrings 
{
	Param(
	  [switch] $overWrite,
	  [Parameter(Mandatory=$true)]
	  [string] $fileName
	)

	if (Test-Path $fileName) 
	{
		if ($overWrite)
		{
			# Remove the file
			Remove-Item $fileName
		}
		else 
		{
			throw "$fileName already Exists ! Cannot overwrite (unless specified)"
		}
	}

	$result = @()

	foreach ($file in Get-ChildItem -Recurse *.xml | Where-Object { Select-String "stringResource" $_ -Quiet })
	{
		#Write-Output "Found File $($file.FullName)"
			
		$dbString = New-Object -TypeName PSObject
			
		$mainContent = [xml](Get-Content -Path $file.FullName)
		[xml]$cdata = $mainContent.XFProjectFile.content."#cdata-section"
	
		$dbString | Add-Member -Name "Name" -MemberType Noteproperty -Value $cdata.stringResource.name
		$dbString | Add-Member -Name "WorkSpace" -MemberType Noteproperty -Value $cdata.stringResource.workspace
		$dbString | Add-Member -Name "MaintenanceUnit" -MemberType Noteproperty -Value $cdata.stringResource.maintenanceUnit

		foreach ($v in $cdata.stringResource.textValuesByCulture.textValueByCulture)
		{
			$cultureName = $v.culture
			$dbString | Add-Member -Force -Name $cultureName -MemberType Noteproperty -Value $v.textValue 
		}

		$result += $dbString
	}
	
	$params = @{
		AutoSize      = $true
		TableStyle    = 'Medium11'
		BoldTopRow    = $true
		WorksheetName = 'Strings'
		Path          = $fileName 
	}

	$result | Export-Excel @params
}


function Import-OSStrings 
{
	Param(
	  [Parameter(Mandatory=$true)]
	  [string] $fileName
	)

	if (!(Test-Path $fileName)) 
	{
		throw "$fileName does not Exists !"
	}

	# This is the dictionary that contains all the Paths for Strings, based on WS/MU
	# The Key is composed : <WS>.<MU>
	$stringDirectories = @{}

	$dirsTmp = Get-ChildItem -recurse "Dashboard Strings" -Directory
	foreach ($d in $dirsTmp)
	{
		$m = [regex]::Matches($d, 'Application Workspaces\\Workspaces\\(.*)\\Maintenance Units\\(.*)\\Dashboard Strings')
		if ($m.Groups.Length -eq 3)
		{
			# Build the key
			$k = $m.Groups[1].Value + "." + $m.Groups[2].Value
			$stringDirectories.Add($k, $d)
		}
	}

	$data = Import-Excel -Path $fileName

	foreach ($row in $data) 
	{
		if (!$row.Name -or !$row.Workspace -or !$row.MaintenanceUnit)
		{
			continue
		}
		
		$k = $row.Workspace + "." + $row.MaintenanceUnit
		$fileName = $row.Name + ".xml"
		$fullFileName = Join-Path -Path $stringDirectories[$k] -ChildPath $fileName

		Write-Output "$($row.Workspace)/$($row.MaintenanceUnit)/$($row.Name)"

		# Take default value from en-US culture
		$defaultValue = ""
		foreach ($prop in $row.PSObject.Properties)
		{
			if ($prop.Name.ToLower() -eq "en-us")
			{
				$defaultValue = $prop.Value
				break;
			}
		}

		$xmlArray = New-Object System.Collections.Generic.List[string]
		$xmlArray.Add("<XFProjectFile>")
        $xmlArray.Add("    <itemName>$($row.Name)</itemName>")
        $xmlArray.Add("    <projectItemType>DashboardString</projectItemType>")
        $xmlArray.Add("    <projectItemChildType>Unknown</projectItemChildType>")
        $xmlArray.Add("    <sourceCodeFileName />")
        $xmlArray.Add("    <content><![CDATA[<stringResource name=""$($row.Name)"" workspace=""$($row.Workspace)"" maintenanceUnit=""$($row.MaintenanceUnit)"" description="""" isLocalizable=""true"" stringResourceType=""Unknown"" textValue=""$defaultValue"">")
        $xmlArray.Add("    <textValuesByCulture>")

		foreach ($prop in $row.PSObject.Properties)
		{
			# Find the culture properties
			if ($prop.Name -match '^[a-zA-Z]{2}\-[a-zA-Z]{2}$')
			{
				$xmlArray.Add("        <textValueByCulture culture=""$($prop.Name)"" textValue=""$($prop.Value)"" />")
			}
		}

		$xmlArray.Add("    </textValuesByCulture>")
        $xmlArray.Add("</stringResource>]]></content>")
        $xmlArray.Add("</XFProjectFile>")

		$xml = [String]::Join([Environment]::NewLine, $xmlArray) 

		#Write-Output "Write to : $fullFileName"

		$xml | Out-File $fullFileName -NoNewline
	}
}



Export-ModuleMember -Function Show-OSStrings
Export-ModuleMember -Function Export-OSStrings
Export-ModuleMember -Function Import-OSStrings
