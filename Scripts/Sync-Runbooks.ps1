# Used as inline script in release
$Path = Join-Path -Path $ENV:AGENT_RELEASEDIRECTORY -ChildPath '_tine-azure-automation CI\Runbooks\'
$AutomationAccount = 'tine-test-it-aa'
$ResourceGroup = 'tine-infrastructure-rg'
$Files = Get-ChildItem -Path $Path -Recurse | Where-Object {$_.Extension -eq ".ps1"}

 foreach ($file in $files) {

       $runbookname = $file.BaseName
       Write-Host "Publishing $($file.FullName)" -ForegroundColor Green

      $null = Import-AzAutomationRunbook -Name $runbookname -path $file.FullName -Type PowerShell -Force -ResourceGroupName $ResourceGroup -AutomationAccountName $AutomationAccount -Tags @{'Source'='Azure DevOps'}

      $null = Publish-AzAutomationRunbook -Name $runbookname -ResourceGroupName $ResourceGroup -AutomationAccountName $AutomationAccount

 }