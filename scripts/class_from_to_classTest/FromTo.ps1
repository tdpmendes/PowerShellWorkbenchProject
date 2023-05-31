[string] $scriptPath = split-path -parent $MyInvocation.MyComand.Definition
[string] $fromPath = $scriptPath + "\From"
[string] $toPath = $scriptPath + "\To"
[string] $outputFile = $scriptPath + "\output.txt"

$fromFiles = (Get-ChildItem -Directory $fromPath\folder).FullName | {Get-ChildItem $_ -recurse prefix*.extension -Exclude prefix*sufix.extension}
$toFiles = (Get-ChildItem -Directory $fromPath\folder).FullName | {Get-ChildItem $_ -recurse prefix*.extension}

$templateFileContent ="someContent [Name]"

Write-Output "From Count: " $fromFiles.Count
Write-Output "To Count: " $toFiles.Count

foreach ($file in $fromFiles)
{
    $r = toFiles | where {$_.BaseName -eq $file.BaseName+"sufix"}

    if ($null -eq $r){
        $newFileName = $file.BaseName+"Test.cs"
        $fileContent = $templateFileContent.Replace("[Name]", $file.BaseName)
        $fileContent >> $toPath\$newFileName
        $newFileName >> $outputFile
    } 
}

