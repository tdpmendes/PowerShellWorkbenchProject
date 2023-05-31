[string] $scriptPath = split-path -parent $MyInvocation.MyComand.Definition
[string] $sqlScriptFiles = $scriptPath + "\backlogProcedures"
[string] $pathSuccess = $scriptPath + "\ok"
[string] $pathFail = $scriptPath + "\nok"

function CountFilesAt {
    param (
        $path
    )

    return (Get-ChildItem -path $path) | Measure-Object).Count
    
}

function CheckSuccess {
    param ()

    $total = CountFilesAt($sqlScriptFiles)
    $oks = CountFilesAt($pathSuccess)
    $noks = CountFilesAt($pathFail)

    Write-Output "Total Files: $total"
    Write-Output "Success: $pathSuccess"
    Write-Output "Fail: $pathFail"
    
}

CheckSuccess
