# dir env: # Useful for troubleshooting
# tree $env:BUILD_REPOSITORY_LOCALPATH # Useful for troubleshooting

$RunbookPath = Join-Path $env:BUILD_REPOSITORY_LOCALPATH "Runbooks"
$TestsPath = Join-Path $env:BUILD_REPOSITORY_LOCALPATH "Tests"

if (-not (Get-PackageProvider | Where-Object name -eq 'NuGet')) {

    Install-PackageProvider -Name Nuget -Scope CurrentUser -Force -Confirm:$false

}

if (-not (Get-Module -Name Pester -ListAvailable | Where-Object Version -eq '4.8.1') ) {

    Write-Output 'Installing Pester'
    Install-Module -Name Pester -Scope CurrentUser -Force -Confirm:$false -RequiredVersion 4.8.1

}

if (-not (Get-Module -Name PSScriptAnalyzer -ListAvailable | Where-Object Version -eq '1.18.3') ) {

    Write-Output 'Installing PSScriptAnalyzer'
    Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force -Confirm:$false -RequiredVersion 1.18.3

}

Import-Module Pester
Import-Module PSScriptAnalyzer

Set-Location $RunbookPath

$PSSATestsPath = Join-Path $ENV:SYSTEM_DEFAULTWORKINGDIRECTORY 'PSSAResults.xml'
$PSSATests = Invoke-Pester -Script @{
    Path       = Join-Path -Path $TestsPath -ChildPath 'PSSA.tests.ps1'
    Parameters = @{ScriptRoot = $RunbookPath}
} -OutputFormat 'NUnitXml' -OutputFile $PSSATestsPath -PassThru

$RunbookTestsPath = Join-Path $ENV:SYSTEM_DEFAULTWORKINGDIRECTORY 'RunbookResults.xml'
$RunbookTests = Invoke-Pester -Script @{
    Path = Join-Path -Path $TestsPath -ChildPath 'Runbooks.tests.ps1'
} -OutputFormat 'NUnitXml' -OutputFile $RunbookTestsPath -PassThru

$Failed = @()
$Failed = $RunbookTests.TestResult | Where-Object Passed -ne True | Select-Object Name
$Failed = $PSSATests.TestResult | Where-Object Passed -ne True | Select-Object Name

If ($Failed) {

Write-Warning 'Tests failed:'
    $Failed

}