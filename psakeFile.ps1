task default -depends test

task Pester -FromModule PowerShellBuild -Version 0.3.1

task UpdateAzEndpoints {
    $locations      = Get-AzLocation
    $resourceGroups = Get-AzResourceGroup

    # These aren't working right now
    $exclude = @(
        'australiacentral2'
        'uaecentral'
        'southafricawest'
        'germanywestcentral'
        'francesouth'
    )

    $locations = $locations.Where({
        $_.Location -notin $exclude
    })

    $storageEndpoints = Get-Content ./AzSpeedTest/Private/storageLocations.json | ConvertFrom-Json

    foreach ($loc in $locations) {
        $rgName = "storage-$($loc.Location)"
        Write-Host "Setting up location [$rgName]"

        if (-not ($rg = Get-AzResourceGroup -Name $rgName -ErrorAction SilentlyContinue)) {
            $rg = New-AzResourceGroup -Name $rgName -Location $loc.Location -Verbose -Force
        }

        $existingStorage = Get-AzStorageAccount -ResourceGroupName $rgName -ErrorAction SilentlyContinue
        if (-not $existingStorage) {
            $storageName = 'azspeed{0}' -f [guid]::NewGuid().ToString().Split('-')[0]
        } else {
            $storageName = $existingStorage.StorageAccountName
        }

        if (-not ($storageAcct = Get-AzStorageAccount -Name $storageName -ResourceGroupName $rg.ResourceGroupName -ErrorAction SilentlyContinue)) {
            $storageParams = @{
                Name                   = $storageName
                ResourceGroupName      = $rg.ResourceGroupName
                Location               = $loc.Location
                SkuName                = 'Standard_LRS'
                Kind                   = 'StorageV2'
                EnableHttpsTrafficOnly = $true
            }
            $storageAcct = New-AzStorageAccount @storageParams -Verbose
        }

        if (-not ($container = Get-AzStorageContainer -Name speedtest -Context $storageAcct.Context -ErrorAction SilentlyContinue)) {
            $container = New-AzStorageContainer -Name speedtest -Permission Container -Context $storageAcct.Context -Verbose
        }

        if (-not ($blob = Get-AzStorageBlob -Container speedtest -Blob test.txt -Context $container.Context -ErrorAction SilentlyContinue)) {
            $blob = $container | Set-AzStorageBlobContent -File './test.txt' -Blob 'test.txt' -Force -Verbose
        }

        if (-not ($storageEndpoints.Where({$_.Name -eq $storageName}))) {
            $storageEndpoints += [pscustomobject][ordered]@{
                Name     = $storageName
                Location = $loc.Location
                TestUri  = 'https://{0}.blob.core.windows.net/speedtest/test.txt' -f $storageName
            }
        }
    }

    $storageEndpoints | ConvertTo-Json | Out-File ./AzSpeedTest/Private/storageLocations.json -Encoding utf8
}
