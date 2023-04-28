$PSSATestsPath = Join-Path $ENV:SYSTEM_DEFAULTWORKINGDIRECTORY 'PSSAResults.xml' 
$RunbookTestsPath = Join-Path $ENV:SYSTEM_DEFAULTWORKINGDIRECTORY 'RunbookResults.xml'

[xml]$PSSATests = Get-Content -Path $PSSATestsPath
[xml]$RunbookTests = Get-Content -Path $RunbookTestsPath

$FailedCount = 0

if ($PSSATests.'test-results'.failures -gt 0) {
 
    
    $FailedCount += $PSSATests.'test-results'.failures

}

if ($RunbookTests.'test-results'.failures -gt 0) {
 
    $FailedCount += $RunbookTests.'test-results'.failures

}

Write-Output "Failed count: $FailedCount"

if ($FailedCount -gt 0) {

    throw "One or more tests failed, see test results for details. Aborting release."

}