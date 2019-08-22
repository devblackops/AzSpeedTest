
describe Get-AzRegion {
    context 'Output' {
        it 'Returns the correct number of Azure regions' {
            (Get-AzRegion).Count | should -be 30
        }
    }
}
