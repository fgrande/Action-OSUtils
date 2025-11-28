<#

.Synopsis
Build snippet based on files having specific format.

.Description
Build snippet based on files having specific format (see AWSnippets project)

.Parameter baseDir
If specified, it's the starting point for searching the files. If not specified is the current folder..

.Parameter zipFileName
Name of the resulting zip File 

.Parameter author
Name of the author. Default is Avvale

.Example
PS> Build-Snippets -baseDir C:\Works\OneStream\Projects\AWSnippets -zipFileName c:\temp\awsnippets.zip

#>

function Build-Snippets 
{
	Param(
	  [string] $baseDir,
	  [Parameter(Mandatory=$true)]
	  [string] $zipFileName,
	  [string] $author = "Avvale"
	)
	
	$result = @()

	if ([string]::IsNullOrEmpty($baseDir))
	{
		$baseDir = Get-Location
	}

	$xmlHeader = "<?xml version=""1.0"" encoding=""utf-8""?>
                  <OneStreamXF version=""6.2.0.11708"">
                    <brSnippetsRoot>
                      <clear author=""$author"" />
                      <brSnippets>"

	$xmlFooter = "    </brSnippets>
                    </brSnippetsRoot>
                  </OneStreamXF>"

	$xmlSnippet = "<brSnippet languageType=""||LanguageType||"" moduleType=""||ModuleType||"" category=""||Category||"" subCategory=""||SubCategory||"" name=""||Name||"">
                     <description>||Description||</description>
                     <author>$author</author>
                     <searchTerms>||SearchTerms||</searchTerms>
                     <content><![CDATA[||ScriptContent||]]></content>
                   </brSnippet>"
	
	$snippetsDir = "$baseDir\\Snippets"
	Write-Output "Checking Dir (new): " $snippetsDir

	$xmlHeaderFileNameWithoutExtension = "$baseDir\\Commons\\PreSnippet"
	$xmlFooterFileNameWithoutExtension = "$baseDir\\Commons\\PostSnippet"

	$tempXMLFile = New-TemporaryFile

	#Write-Host $tempXMLFile
	$xmlHeader | Out-File $tempXMLFile -Append

	foreach ($file in Get-ChildItem -Path $snippetsDir -Recurse -Include *.cs, *.vb)
	{
		#Write-Output "Found File $($file.FullName)"

		if ($file.BaseName.ToLower().StartsWith("todo_"))
		{
			continue
		}

		$extension = $file.Extension
		$subCategory = $file.Directory.BaseName
		$category = $file.Directory.Parent.BaseName
		$moduleType = $file.Directory.Parent.Parent.BaseName

		$name = ""
		$description = ""
		$searchTerms = ""

		$scriptContent = ""

		$languageType = "";
		switch ($extension)
		{
			".cs" { $languageType = "CSharp" }
			".vb" { $languageType = "VisualBasic" }
		}

		$lineNo = 0
		foreach($line in Get-Content $file.FullName) 
		{
			switch ($lineNo)
			{
				0 { $name = $line.Replace("///", "").Trim() }
				1 { $description = $line.Replace("///", "").Trim() }
				2 { $searchTerms = $line.Replace("///", "").Trim() }
				3 {  }
				default { $scriptContent = "$scriptContent`r`n$line" }
			}

			$lineNo++
        }

		#Write-Host $extension " => " $moduleType " => " $category " => " $subCategory " => " $name " => " $description " => " $searchTerms

		$scriptHeader = Get-Content -Path "$xmlHeaderFileNameWithoutExtension$extension"
		$scriptFooter = Get-Content -Path "$xmlFooterFileNameWithoutExtension$extension"

		$fullScriptContent = ""
		if ($scriptHeader)
		{
			$fullScriptContent = $scriptHeader
		}
		$fullScriptContent = "$fullScriptContent`r`n$scriptContent"
		if ($scriptFooter)
		{
			$fullScriptContent = "$fullScriptContent`r`n$scriptFooter"
		}

		$xmlDecoded = $xmlSnippet
		$xmlDecoded = $xmlDecoded.Replace("||LanguageType||", $languageType) 
		$xmlDecoded = $xmlDecoded.Replace("||ModuleType||", $moduleType) 
		$xmlDecoded = $xmlDecoded.Replace("||Category||", $category) 
		$xmlDecoded = $xmlDecoded.Replace("||SubCategory||", $subCategory) 
		$xmlDecoded = $xmlDecoded.Replace("||Name||", $name) 
		$xmlDecoded = $xmlDecoded.Replace("||Description||", $description) 
		$xmlDecoded = $xmlDecoded.Replace("||SearchTerms||", $searchTerms) 
		$xmlDecoded = $xmlDecoded.Replace("||ScriptContent||", $fullScriptContent) 

		$xmlDecoded | Out-File $tempXMLFile -Append

		#Write-Host $xmlDecoded
		#Write-Host ""
		#Write-Host "========================="
		#Write-Host ""
	}

	$xmlFooter | Out-File $tempXMLFile -Append

	# zip file to destination
	$tempBasePath = [io.path]::GetDirectoryName($tempXMLFile)
	$finalFileName = "AWSnippets.xml"
	$finalFullFileName = [io.path]::Join($tempBasePath, $finalFileName)
	#Write-Host $tempXMLFile
	#Write-Host $tempBasePath
	#Write-Host $finalFullFileName

	Rename-Item -Path $tempXMLFile -NewName $finalFileName
	Compress-Archive -Path $finalFullFileName -DestinationPath $zipFileName -Update

	# delete temporary file
	Remove-Item -Path $finalFullFileName
	
	return $result
}



Export-ModuleMember -Function Build-Snippets
