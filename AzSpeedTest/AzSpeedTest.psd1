@{
    RootModule        = 'AzSpeedTest.psm1'
    ModuleVersion     = '0.1.0'
    GUID              = 'fcfcc2a4-8f06-417d-b02d-d45ea2b99054'
    Author            = 'Brandon Olin'
    CompanyName       = 'Community'
    Copyright         = '(c) Brandon Olin. All rights reserved.'
    Description       = 'Azure speed test for PowerShell'
    PowerShellVersion = '3.0'
    RequiredModules   = @()
    TypesToProcess    = @()
    FormatsToProcess  = @()
    FunctionsToExport = @(
        'Get-AzRegion'
        'Test-AzRegionLatency'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
    PrivateData       = @{
        PSData = @{
            Tags = @('PSEdition_Core', 'Azure', 'Speed', 'Test')
            # LicenseUri = ''
            # ProjectUri = ''
            # IconUri = ''
            # ReleaseNotes = ''
        }
    }
}
