properties {
    $projectRoot = $ENV:BHProjectPath
    if(-not $projectRoot) {
        $projectRoot = $PSScriptRoot
    }

    $sut = Join-Path $projectRoot $env:BHProjectName
    $tests = Join-Path $projectRoot Tests

    $psVersion = $PSVersionTable.PSVersion.Major
}

task default -depends Test

task Init {
    "`nSTATUS: Testing with PowerShell $psVersion"
    "Build System Details:"
    Get-Item ENV:BH*
} -description 'Initialize build environment'

task Test -Depends Init, Analyze, Pester -description 'Run test suite'

task Analyze -Depends Init {
    $saResults = Invoke-ScriptAnalyzer -Path $sut -Severity Error -Recurse -Verbose:$false
    if ($saResults) {
        $saResults | Format-Table
        Write-Error -Message 'One or more Script Analyzer errors/warnings where found. Build cannot continue!'
    }
} -description 'Run PSScriptAnalyzer'

task Pester -Depends Init {
    if(-not $ENV:BHProjectPath) {
        Set-BuildEnvironment -Path $PSScriptRoot\..
    }
    Remove-Module $ENV:BHProjectName -ErrorAction SilentlyContinue
    Import-Module (Join-Path $ENV:BHProjectPath $ENV:BHProjectName) -Force

    if (Test-Path -Path $tests) {
        Invoke-Pester -Path $tests -PassThru -EnableExit
    }
} -description 'Run Pester tests'

task ExportFunctions {
    $functions = Get-ChildItem -Path (Join-Path $sut Public) -Filter '*.ps1' -File
    Update-ModuleManifest -Path $env:BHPSModuleManifest -FunctionsToExport $functions.BaseName
}

task Publish -depends Test, ExportFunctions {
    $version = (Import-PowerShellDataFile -Path $env:BHPSModuleManifest).ModuleVersion

    assert {
        -not (Find-Module -Name $env:BHProjectName -RequiredVersion $version -Repository PSGallery)
    } -failureMessage "Version [$version] is already published to the gallery. Bump the version before publishing."

    Publish-Module -Path $env:BHModulePath -NuGetApiKey '$env:PSGalleryApiKey' -Repository PSGallery -Verbose -WhatIf
}
