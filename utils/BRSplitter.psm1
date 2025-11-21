<#

.Synopsis
Extract Business Rules from xfProject, creating XML files ready to be uploaded

.Description
Extract Business Rules from xfProject, creating XML files ready to be uploaded

.Parameter sourceXFProject
The XFProject File definition to get sources from

.Parameter destPath
Destination Path for manipulated files

.Example
PS> Split-BRules C:\Works\OneStream\Projects\AWUtils\AWUtils.xfProj c:\temp\awutils

#>

function Split-BRules 
{
	Param(
	  [Parameter(Mandatory=$true)]
	  [string] $sourceXFProject,
	  [Parameter(Mandatory=$true)]
	  [string] $destPath,
	  [string] $osVersion="8.5.1.17017",
	  [switch] $zipped,
	  [string] $zipFileName = ""
	)

	# Check if the source file name ends with xfProj
	if (!$sourceXFProject.EndsWith(".xfProj"))
	{
		throw "$sourceXFProject should be an xfProject File !"
	}

	# First of all the XFProject file must exists, otherwise we exit with an error
	if (!(Test-Path -Path $sourceXFProject -PathType leaf))
	{
		throw "$sourceXFProject doesn't exist - Looks like this is not a OneStream's Project !"
	}

	# Check if dest Path Exists
	# If Directory doesn't exists, let's create it 
	if (!(Test-Path -Path $destPath))
	{
		New-Item -Path $destPath -ItemType "Directory" > $null
	}

	$header = "<?xml version=""1.0"" encoding=""utf-8""?><OneStreamXF version=""$osVersion""><extensibilityRulesRoot>"
	$footer = "</extensibilityRulesRoot></OneStreamXF>"

	# Get BasePath (the path in which the XFProject file is included)
	$basePath = Split-Path -Path $sourceXFProject -Parent -Resolve

	# Get all Business Rules Defined
	foreach ($file in Get-ChildItem -Path $basePath -Recurse *.xml | Where-Object { Select-String "<projectItemType>BusinessRule</projectItemType>" $_ -Quiet })
	{
		Write-Output "Found File $($file.FullName)"
		
		$brFileName = [io.path]::GetFileName($file.FullName)
						
		$mainContent = [xml](Get-Content -Path $file.FullName)
		
		$sourceCode = $mainContent.XFProjectFile.content."#cdata-section"[0] + $mainContent.XFProjectFile.content."#cdata-section"[1]
		$fullSourceCode = "$header$sourceCode$footer"

		$finalFullName = Join-Path -Path $destPath -ChildPath $brFileName

		$fullSourceCode | Out-File -FilePath $finalFullName
	}

	if ($zipped)
	{
		$currentDir = Get-Location

		Set-Location $destPath

		if ($zipFileName)
		{
			# Zip all the destination directory in one zip file
			$zipFileName = Join-Path -Path $destPath -ChildPath $zipFileName
			if (Test-Path -Path $zipFileName -PathType leaf)
			{
				Remove-Item $zipFileName
			}
			tar -acf $zipFileName "*.xml"

			Remove-Item "$destPath\*.xml"
		}
		else {
			foreach ($file in Get-ChildItem -Path $destPath *.xml)
			{
				$fileName = $file.FullName

				$zipFileName = [io.path]::GetFileNameWithoutExtension($fileName) + ".zip"
				$zipFileName = Join-Path -Path $destPath -ChildPath $zipFileName

				$sourceFilename = [io.path]::GetFileName($fileName)

				Write-Host "Zipping ${fileName} => $zipFileName"
				tar -acf $zipFileName $sourceFilename

				Remove-Item $fileName
			}
		}

		Set-Location $currentDir
		
	}
	
	return $result
}


Export-ModuleMember -Function Split-BRules
