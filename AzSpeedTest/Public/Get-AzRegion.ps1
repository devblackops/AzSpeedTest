function Get-AzRegion {
    <#
    .SYNOPSIS
    Return a list of Azure Regions.
    .DESCRIPTION
    Return a list of Azure regions.
    .EXAMPLE
    PS C:\> Get-AzRegion
    australiacentral
    australiaeast
    australiasoutheast
    brazilsouth
    canadacentral
    canadaeast
    centralindia
    centralus
    eastasia
    eastus
    eastus2
    francecentral
    japaneast
    japanwest
    koreacentral
    koreasouth
    northcentralus
    northeurope
    southafricanorth
    southcentralus
    southeastasia
    southindia
    uaenorth
    uksouth
    ukwest
    westcentralus
    westeurope
    westindia
    westus
    westus2
    #>
    [OutputType([string[]])]
    [cmdletbinding()]
    param()

    $script:storageLocations | Select-Object -ExpandProperty Location | Sort-Object
}
