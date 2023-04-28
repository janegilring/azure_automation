param (
    [Parameter(Mandatory = $true)]
    [string]
    $ComputerName
)

<#

 NAME: Restart-Server.ps1

 AUTHOR: Jan Egil Ring
 EMAIL: jan.egil.ring@crayon.com

 COMMENT: Runbook to invoke server restart


 VERSION HISTORY:
 1.0 22.06.2018 - Initial release

 #>

Write-Output -InputObject "Runbook Restart-Server started $(Get-Date) on Azure Automation Runbook Worker $($env:computername)"


#region Variables

Write-Output -InputObject 'Getting variables from Azure Automation assets...'

$NodeCredential = Get-AutomationPSCredential -name 'cred-LimitedServerAdmin'

#endregion

Write-Output -InputObject 'Testing connectivity'
$PingStatus = Test-NetConnection -ComputerName $ComputerName -InformationLevel Quiet

if ($PingStatus) {

    Write-Output -InputObject "Setting computer $ComputerName in maintenance mode in SCOM..."

    $null = .\Start-SCOMMaintenanceMode.ps1 -ComputerName $ComputerName -Comment 'Automatic maintenance run from Azure Automation - scheduled reboot' -DurationInMinutes 10


    Write-Output -InputObject "Rebooting computer $ComputerName"

    try {

        Restart-Computer -Protocol DCOM -ComputerName $ComputerName -Force -Credential $NodeCredential -ErrorAction Stop

        Write-Output -InputObject "Successfully initiated restart of computer $ComputerName"

    }

    catch {

        Write-Output -InputObject "An error occured when trying to restart computer $ComputerName : $($_.Exception.Message)"

    }

} else {

    Write-Output -InputObject "Computer $ComputerName not responding to ping - skipping reboot attempt"

}


Write-Output -InputObject "Runbook Restart-Server finished $(Get-Date)"