---
external help file: AzSpeedTest-help.xml
Module Name: AzSpeedTest
online version:
schema: 2.0.0
---

# Test-AzRegionLatency

## SYNOPSIS
Tests network latency to one or more Azure regions.

## SYNTAX

```
Test-AzRegionLatency [[-Iterations] <Int32>] [[-DelaySeconds] <Int32>] [[-DelayMilliseconds] <Int32>]
 [-Region <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Tests network latency to one or more Azure regions.

## EXAMPLES

### EXAMPLE 1
```
Test-AzRegionLatency -Region westus
```

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

### EXAMPLE 2
```
$results = Test-AzRegionLatency -Region eastus -Iterations 300 -DelaySeconds 1
```

Test the network latency from the local comptuer to the East US Azure region.
Run this test for 5 minutes and delay each iteration by 1 second.

## PARAMETERS

### -Iterations
The number of test iterations to run in each region.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: 100
Accept pipeline input: False
Accept wildcard characters: False
```

### -DelaySeconds
An optional number of seconds to wait between each iteration.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -DelayMilliseconds
An optional number of milliseconds to wait between each iteration.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Region
The region(s) to test.
By default ALL available Azure regions will be tested.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES

## RELATED LINKS
