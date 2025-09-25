<#

.Synopsis
Extract and manipulate source files to get them ready for building documentation

.Description
Extract and manipulate source files to get them ready for building documentation

.Parameter sourceXFProject
The XFProject File definition to get sources from

.Parameter destPath
Destination Path for manipulated files

.Parameter wsNamespacePrefix
The string to replace the __WsNamespacePrefix in sources

.Parameter wsAssemblyName
The string to replace the wsAssemblyName in sources

.Example
PS> Format-OSSources C:\Works\OneStream\Projects\AWCommons\AWCommons.xfProj c:\temp\test -forceOverWrite -wsNameSpacePrefix "AWCommons" -wsAssemblyName "Commons"

#>

function Format-OSSources 
{
	Param(
	  [Parameter(Mandatory=$true)]
	  [string] $sourceXFProject,
	  [Parameter(Mandatory=$true)]
	  [string] $destPath,
	  [string] $wsNamespacePrefix,
	  [string] $wsAssemblyName,
	  [switch] $forceOverWrite
	)

	$wsNamespacePrefixOriginal = "__WsNamespacePrefix"
	$wsAssemblyNameOriginal = "__WsAssemblyName"

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

	# If dest exists and is requested Overwriting, I should delete it before go on
	if ($forceOverWrite -and (Test-Path -Path $destPath))
	{
		Remove-Item -Recurse -Force $destPath
	}

	# Check if dest Path Exists
	# If exists and is not empty => error (better not erase automatically path)
	# If not exists => create it
	if ((Test-Path -Path $destPath) -and ((Get-ChildItem -Path $destPath -Force | Measure-Object).Count -gt 0))
	{
		throw "$destPath Already exists (and is not empty) !"
	}
	else 
	{
		# If Directory doesn't exists, let's create it 
		if (!(Test-Path -Path $destPath))
		{
			New-Item -Path $destPath -ItemType "Directory" > $null
		}
	}

	# Get BasePath (the path in which the XFProject file is included)
	$basePath = Split-Path -Path $sourceXFProject -Parent -Resolve

	# Get all CS source files (from assemblies)
	foreach ($file in Get-ChildItem -Path $basePath -Recurse *.cs)
	{
		#Write-Host $file " => " $destPath "\n"
		Copy-Item $file -Destination $destPath
	}

	# Get all VB source files (from assemblies)
	foreach ($file in Get-ChildItem -Path $basePath -Recurse *.vb)
	{
		#Write-Host $file " => " $destPath "\n"
		Copy-Item $file -Destination $destPath
	}

	# Get all Business Rules Defined
	foreach ($file in Get-ChildItem -Path $basePath -Recurse *.xml | Where-Object { Select-String "<projectItemType>BusinessRule</projectItemType>" $_ -Quiet })
	{
		#Write-Output "Found File $($file.FullName)"
		
		$brFileName = [io.path]::GetFileNameWithoutExtension($file.FullName)
						
		$mainContent = [xml](Get-Content -Path $file.FullName)
		[xml]$mainCData = $mainContent.XFProjectFile.content."#cdata-section"[0] + $mainContent.XFProjectFile.content."#cdata-section"[1]

		#Write-Host $mainCData.InnerXml

		$languageType = $mainCData.businessRule.businessRuleLanguageType

		$extension = ".xxx"
		switch ($languageType)
		{
			'CSharp' { $extension = ".cs" }
			'VisualBasic' { $extension = ".vb" }
		}

		$sourceCode = $mainCData.businessRule.sourceCode."#cdata-section"

		#Write-Host $sourceCode

		$finalFileName = $brFileName + $extension
		$finalFullName = Join-Path -Path $destPath -ChildPath $finalFileName

		#Write-Host "Writing to : " $finalFullName
	
		# Put the code in the destination file
		$sourceCode | Out-File -FilePath $finalFullName
	}

	# Now all files and BRules are in dest folder.
	# It's time to replace Namespace and Assembly Name (if defined)
	foreach ($file in Get-ChildItem -Path $destPath -Recurse)
	{
		if ($wsNamespacePrefix)
		{
			((Get-Content -path $file -Raw) -replace $wsNamespacePrefixOriginal, $wsNamespacePrefix) | Set-Content -Path $file
		}
		if ($wsAssemblyName)
		{
			((Get-Content -path $file -Raw) -replace $wsAssemblyNameOriginal, $wsAssemblyName) | Set-Content -Path $file
		}
	}
	
	return $result
}


Export-ModuleMember -Function Format-OSSources 
