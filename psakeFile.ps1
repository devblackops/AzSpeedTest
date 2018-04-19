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
        Set-BuildEnvironment -Path $PSScriptRoot/..
    }
    Remove-Module $ENV:BHProjectName -ErrorAction SilentlyContinue
    Import-Module (Join-Path $ENV:BHProjectPath $ENV:BHProjectName) -Force

    $testResultsPath = Join-Path $PSScriptRoot testResults.xml
    $pesterParams = @{
        Path         = './Tests'
        OutputFile   = $testResultsPath
        OutputFormat = 'NUnitXml'
        PassThru     = $true
        PesterOption = @{
            IncludeVSCodeMarker = $true
        }
    }
    $testResults = Invoke-Pester @pesterParams

    # Upload test artifacts to AppVeyor
    if ($env:APPVEYOR_JOB_ID) {
        $wc = New-Object 'System.Net.WebClient'
        $wc.UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", $testResultsPath)
    }

    if ($testResults.FailedCount -gt 0) {
        throw "$($testResults.FailedCount) tests failed!"
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

    Publish-Module -Path $env:BHModulePath -NuGetApiKey $env:PSGalleryApiKey -Repository PSGallery -Verbose
}
