[![Build status][appveyor-badge]][appveyor-build]
[![PowerShell Gallery][psgallery-badge]][psgallery]
# AzSpeedTest

## Overview

An [Microsoft Azure](https://azure.microsoft.com) speed test module for PowerShell.
This module performs basic network latency tests to one or more Azure regions and returns the results.

## Why Would You Care About Latency?

You can use this module to determine the closest (network-wise) Azure region to you.
This information can be helpful in determinining where best to deploy your Azure resources.
## Installation

The easiest and prefered way to install AzSpeedTest is via the [PowerShell Gallery](https://www.powershellgallery.com/).
To use the PowerShell Gallery,
you must be on Windows 10, have PowerShell 5, or PowerShell 3 or 4 with the [PowerShellGet](http://go.microsoft.com/fwlink/?LinkID=746217&clcid=0x409)
module.
See the [PowerShell Gallery Getting Started](https://www.powershellgallery.com/GettingStarted?section=Get%20Started) page for more information.
Run the following command to install AzSpeedTest.

```powershell
C:\> Install-Module -Name AzSpeedTest -Repository PSGallery
C:\> Import-Module AzSpeedTest
```

## Usage

Get the list of available Azure regions to test.

```powershell
C:\> Get-AzRegion
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
southcentralus
southeastasia
southindia
uksouth
ukwest
westcentralus
westeurope
westindia
westus
westus2
```

Test the latency to the `westus` Azure region. Run 50 iterations and display the results.

```powershell
C:\> $results = Test-AzRegionLatency -Region westus -Iterations 50
C:\> $results | Format-List
RawResults   : {@{Time=4/18/18 9:44:59 PM; Timespan=00:00:00.2962200; LatencyMS=296}, @{Time=4/18/18
               9:44:59 PM; Timespan=00:00:00.0344670; LatencyMS=34}, @{Time=4/18/18 9:45:00 PM;
               Timespan=00:00:00.0324620; LatencyMS=32}, @{Time=4/18/18 9:45:00 PM;
               Timespan=00:00:00.0346950; LatencyMS=34}...}
ComputerName : HDK38433FJ
TotalTime    : 00:00:02.1108190
Region       : westus
Maximum      : 296
Average      : 38.32
Minimum      : 31
```

[appveyor-badge]: https://ci.appveyor.com/api/projects/status/pc9tyep74esefx5r?svg=true
[appveyor-build]: https://ci.appveyor.com/project/devblackops/azspeedtest
[psgallery-badge]: https://img.shields.io/powershellgallery/dt/AzSpeedTest.svg
[psgallery]: https://www.powershellgallery.com/packages/AzSpeedTest
