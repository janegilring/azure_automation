param(
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $VmName,
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionName,
    [Parameter(Mandatory = $true)]
    [string]
    $NewVmSize
)

<#

 NAME: Resize-AzVm.ps1

 AUTHOR: Jan Egil Ring

 COMMENT: Runbook to resize an Azure Virtual Machine.

 Logic:

        -Connect to Azure using credentials stored in Automation
        -Test whether VM exists on the specified Azure subscription/resource group
            -If yes:
                -Delete existing VM
                -Create specified availability set if it does not exist
                -Create VM into specified availability set using the same configuration as the deleted VM
            -If no: No further actions

 #>

try {

    Import-Module -Name Az.Compute -RequiredVersion 4.24.1 -ErrorAction Stop

}

catch {

    Write-Error -Message 'Prerequisites not installed (PowerShell module Az.Compute version 4.24.1 not installed)'
    throw $_.Exception

}

try {

    $null = Connect-AzAccount -Identity -ErrorAction Stop
    $null = Set-AzContext $SubscriptionName -ErrorAction Stop

} catch {

    Write-Error -Message $_.Exception
    throw $_.Exception
}

Write-Output "Resize VM $VmName to size $NewVmSize"

    Stop-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -Force
    $VM = Get-AzVM -ResourceGroupName $ResourceGroupName -VMName $VmName
    $VM.HardwareProfile.VmSize = $NewVmSize
    Update-AzVM -VM $VM -ResourceGroupName $ResourceGroupName
    Start-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName

Write-Output "Runbook completed"