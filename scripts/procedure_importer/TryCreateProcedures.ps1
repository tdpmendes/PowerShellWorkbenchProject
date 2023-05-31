#"Hostname\SQLEXPRESS"
[string] $sqlServer =           $scriptPath + "your server host name here like the example above"
[string] $outputSql =           $scriptPath + "databaseName"
[string] $scriptPath =          split-path -parent $MyInvocation.MyComand.Definition
[string] $sqlScriptFiles =      $scriptPath + "\procs"
[string] $pathSuccess =         $scriptPath + "\ok"
[string] $pathFail =            $scriptPath + "\nok"
[string] $errorReportFile =     $scriptPath + "\errorReport.txt"
[string] $driver =              "{ODBC Driver 17 for SQL Server}"
[string] $connectionString =    "Driver=$driver;SERVER=$sqlServer;Database=$databaseName;Trusted_Connection=Yes;"

function ExecuteSQL {
    param (
        $Content
    )

    $conn = New-Object System.Data.Odbc.OdbcConnection
    $conn.ConnectionString = $connectionString 
    
    try {
        Write-Output $Content
        $conn.open()
        $cmd = New-Object System.Data.Odbc.OdbcCommand $Content $conn
        $affectedRows = $cmd.ExecuteNonQuery()
        Write-Output ("affected rows: $affectedRows") 
    }
    catch [System.Exception]{
        Write-Error ($_)
        throw $_
    }
    finally {
        $conn.Close()
        Write-Output("".PadRight(60,'*'))
    }
} 

function CleanUp {
    param (
        $fileContent
    )
    
    #DO NOT REMOVE THIS CARRIAGE RETURN
    $lookupWords = "USE [$databaseName]", "GO
", "SET ANSI_NULLS OFF","SET ANSI_NULLS ON", "SET QUOTED_IDENTIFIER ON"

    foreach ($item in $lookupWords) {
        $fileContent = $fileContent.Replace($item,"")
    }

    return $fileContent
}

function ExecuteSqlScript {
    param (
        [String] $sqlScriptFile,
        [String] $sqlServer,
        [String] $databaseName
    )
    
    $sqlBuilder = New-Object System.Text.StringBuilder
    $fileContent = [System.IO.File]::ReadAllLines($sqlScriptFile)

    try {
        $filecontent = CleanUp $fileContent
        ExecuteSQL $fileContent
        Move-Item -Path $sqlScriptFile $pathSuccess
    } catch [System.Exception]{
        $errorMessage = "Error in file: $sqlScriptFile"
        Write-Error ($errorMessage)
        $errorMessage + $_.Exception >> $errorReportFile
        Move-Item -Path $sqlScriptFile $pathFail
    } finally {
        [void]$sqlBuilder.Clear()
    }

}

foreach ($file in Get-ChildItem -path $sqlScriptFile) {
    ExecuteSqlScript $sqlScriptFile\$file $sqlServer $databaseName
}