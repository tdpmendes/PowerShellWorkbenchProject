[string] $scriptPath =      split-path -parent $MyInvocation.MyComand.Definition
[string] $csvsToImport =    $scriptPath + "\csvsToImport"
[string] $outputSql =       $scriptPath + "\insertScripts"
[string] $pathSuccess =     $scriptPath + "\ok"
[string] $pathFail =        $scriptPath + "\nok"
[string] $errorReportFile = $scriptPath + "\errorReport.txt"

function Process-Csv {
    param (
        [string] $csvsToImport
    )
    
    $fileContet = [System.IO.File]::ReadAllLines($csvsToImport)
    $pathSplit = $csvsToImport.Split('\')
    $fileName = $pathSplit[$pathSplit.Count-1].Split('.')[0]

    try {
        Consume-Csv $fileName $fileContent
        Move-Item -Path $csvsToImport $pathSuccess
    }
    catch [System.Exception]{
        $errorMessage = "Error in file: "+$csvsToImport
        Write-Error ($errorMessage)
        $errorMessage + $_.Exception >> $errorReportFile
        Move-Item -Path $csvsToImport $pathFail
    }
}

function CleanUp-Value {
    param (
        $value
    )

    if ($value -eq "") return "null"

    if ($value.IndexOf("'") -ne -1)
        $value = $value.Replace("'", "''")
        
    return $value
}

function Consume-Csv {
    param (
        $tableName,
        $content
    )
    
    $insertTemplate = "insert into $tablename ([columns]) values ([values])"

    $columnNames = $content[0]
    $columnNames = $columnNames.Replace(';',',')

    $insertTemplate = $insertTemplate.Replace("[columns]",$columnNames)

    for ($j = 0; $j -lt $currentLine.Count; $j++){
        $value = $currentLine[$j]
        $value = CleanUp-Value $value

        if ($value -ne "null") $value = "'$value'"
        $currentLine = $value
    }

    $values = $currentLine -join ","
    $command = $insertTemplate.Replace("[values]", $values)
    $command >> $outputSql\$tableName".sql"
}

foreach ($file in Get-ChildItem -Path $csvsToImport) {
    Process-Csv $csvsToImport\$file
}