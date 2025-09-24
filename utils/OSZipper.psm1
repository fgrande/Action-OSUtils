# Compress OneStream's Project into a zip file like this:
#
# tar -acf c:\temp\AWCommons.zip --exclude .git *

function Compress-OSProject 
{
	$destDir = "c:\temp"
	
	# Get current directory name
	$dirName = Split-Path -Path (Get-Location) -Leaf
	
	# Build Project File name to search for
	$prjFileName = Join-Path -Path (Get-Location) -ChildPath "$dirName.xfProj"
	
	if (Test-Path -Path $prjFileName -PathType leaf)
	{
		# Build Zip File name
		$zipFileName = Join-Path -Path $destDir -ChildPath "$dirName.zip"
	
		if (Test-Path -Path $zipFileName -PathType leaf)
		{
			Remove-Item $zipFileName
		}
		
		tar -acf $zipFileName --exclude .git *
	}
	else
	{
		Write-Host "$prjFileName doesn't exist - Looks like this is not a OneStream's Project !"
	}
}

Export-ModuleMember -Function Compress-OSProject 
