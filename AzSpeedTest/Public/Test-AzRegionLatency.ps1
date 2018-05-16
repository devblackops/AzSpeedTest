function Test-AzRegionLatency {
    <#
    .SYNOPSIS
    Tests network latency to one or more Azure regions.
    .DESCRIPTION
    Tests network latency to one or more Azure regions.
    .PARAMETER Iterations
    The number of test iterations to run in each region.
    .PARAMETER DelaySeconds
    An optional number of seconds to wait between each iteration.
    .PARAMETER DelayMilliseconds
    An optional number of milliseconds to wait between each iteration.
    .EXAMPLE
    PS C:\> Test-AzRegionLatency -Region westus
    RawResults   : {@{Time=4/18/18 8:54:46 PM; Timespan=00:00:00.0350430; LatencyMS=35}, @{Time=4/18/18 8:54:46 PM;
                   Timespan=00:00:00.0339910; LatencyMS=33}, @{Time=4/18/18 8:54:46 PM; Timespan=00:00:00.0336530; LatencyMS=33},
                   @{Time=4/18/18 8:54:46 PM; Timespan=00:00:00.0349360; LatencyMS=34}...}
    ComputerName : HDK3948GKLD
    TotalTime    : 00:00:03.8771200
    Region       : westus
    Maximum      : 52
    Average      : 35.02
    Minimum      : 32

    Test the network latency from the local computer to the West US Azure region.
    .EXAMPLE
    PS C:\> $results = Test-AzRegionLatency -Region eastus -Iterations 300 -DelaySeconds 1

    Test the network latency from the local comptuer to the East US Azure region. Run this test for 5 minutes and delay each iteration by 1 second.
    #>
    [OutputType([PSCustomObject])]
    [cmdletbinding()]
    param(
        [int]$Iterations = 100,
        [int]$DelaySeconds,
        [int]$DelayMilliseconds
    )

    # Region dynamic parameter
    DynamicParam {
        # Create attribute
        $regionAttribute = [System.Management.Automation.ParameterAttribute]::new()
        $regionAttribute.Mandatory = $false
        $regionAttribute.ValueFromPipeline = $true
        $regionAttribute.Position = 0
        $regionAttribute.ParameterSetName = '__AllParameterSets'
        $regionAttribute.HelpMessage = 'The region(s) to test. By default ALL available Azure regions will be tested.'
        $attributeCollection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
        $attributeCollection.Add($regionAttribute)

        # Create ValidateSet
        $regions = $script:storageLocations | Select-Object -ExpandProperty Location
        $regionValidateSet = New-Object -TypeName System.Management.Automation.ValidateSetAttribute($regions)
        $attributeCollection.Add($regionValidateSet)

        # Create parameter
        $regionParam = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter('Region', [string[]], $attributeCollection)
        $regionParam.Value = $regions
        $PSBoundParameters['Region'] = $regions

        $paramDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        $paramDictionary.Add('Region', $regionParam)
        return $paramDictionary
    }

    begin {
        # Bind the dynamic parameter to a friendly variable
        $Region = $PSBoundParameters['Region']

        $computer = hostname

        $origProgressPref = $ProgressPreference
    }

    process {
        $regionsTested = 0
        foreach ($testRegion in $Region) {
            $testUri = ($script:storageLocations | Where-Object {$_.Location -eq $testRegion}).TestUri

            $regionProgressParams = @{
                Id               = 1
                Activity         = 'Testing latency to Azure regions'
                Status           = "Region: $testRegion"
                CurrentOperation = "Region: $regionsTested of $($Region.Count)"
                PercentComplete  = [int]$regionsTested / $Region.Count * 100
            }
            Write-Progress @regionProgressParams
            Write-Verbose -Message "Testing region [$testRegion]"

            $regionResult = @{
                PSTypeName   = 'AzSpeedTestResult'
                Region       = $testRegion
                ComputerName = $computer
            }

            try {
                $stopwatch = [System.Diagnostics.Stopwatch]::new()

                $iwrParams = @{
                    Uri             = $testUri
                    Verbose         = $false
                    Debug           = $false
                    UseBasicParsing = $true
                }

                $interationTimes = [System.Collections.ArrayList]::new()
                $regionStartTime = Get-Date
                for ($i = 0; $i -lt $Iterations; $i++) {
                    $interationProgressParams = @{
                        Id               = 2
                        ParentId         = 1
                        Activity         = "Testing latency to region: $testRegion"
                        CurrentOperation = "Iteration: $i of $Iterations"
                        PercentComplete  = [int]$i / $Iterations * 100
                    }
                    Write-Progress @interationProgressParams

                    $stopwatch.Start()
                    $ProgressPreference = 'SilentlyContinue'
                    Invoke-WebRequest @iwrParams > $null
                    $ProgressPreference = $origProgressPref
                    $stopwatch.Stop()

                    if ($DelaySeconds) { Start-Sleep -Seconds $DelaySeconds }
                    if ($DelayMilliseconds) { Start-Sleep -Milliseconds $DelayMilliseconds }

                    $iterationResult = [PSCustomObject]@{
                        PSTypeName = 'AzSpeedTestIterationResult'
                        Time       = [DateTime]::Now
                        Timespan   = $stopwatch.Elapsed
                        LatencyMS  = $stopwatch.ElapsedMilliseconds
                    }
                    $interationTimes.Add($iterationResult) > $null

                    $stopwatch.Reset()
                }
                $regionStopTime = [DateTime]::Now
                $totalRegionTestTime = $regionStopTime - $regionStartTime
                $regionResult.Maximum = ($interationTimes | Measure-Object -Property LatencyMS -Maximum).Maximum
                $regionResult.Minimum = ($interationTimes | Measure-Object -Property LatencyMS -Minimum).Minimum
                $regionResult.Average = ($interationTimes | Measure-Object -Property LatencyMS -Average).Average
                $regionResult.TotalTime = $totalRegionTestTime
                $regionResult.RawResults = $interationTimes
                [PSCustomObject]$regionResult
            } catch {
                Write-Error -Message "Failed to test region [$testRegion]"
                Write-Error $_
            } finally {
                $regionsTested++
            }
        }
    }
}
