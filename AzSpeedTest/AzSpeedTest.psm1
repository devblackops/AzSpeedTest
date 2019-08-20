
#Set-StrictMode -Version 2.0

$script:storageLocations = Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Private/storageLocations.json') -Raw |
    ConvertFrom-Json

# Dot source public/private functions
$public =  @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Public/*.ps1') -Recurse -ErrorAction Stop)
$private = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Private/*.ps1') -Recurse -ErrorAction Stop)
foreach ($import in @($public + $private)) {
    try {
        . $import.FullName
    }
    catch {
        throw "Unable to dot source [$($import.FullName)]"
    }
}

Export-ModuleMember -Function $public.BaseName
