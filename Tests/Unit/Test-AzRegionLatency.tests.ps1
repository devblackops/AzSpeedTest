
InModuleScope AzSpeedTest {
    describe 'Test-AzREgionLatency' {

        Mock Invoke-WebRequest {} -Verifiable

        Context 'Behavior' {

            Mock Start-Sleep -MockWith {}

            it 'Runs the correct number of iterations' {
                Test-AzRegionLatency -Region westus -Iterations 42
                Assert-MockCalled -CommandName Invoke-WebRequest -Times  42
            }

            it 'Throws on invalid region' {
                {Test-AzRegionLatency -Region Oz} | should -throw
            }

            it 'Sleeps for correct number of seconds' {
                Test-AzRegionLatency -Region westus -Iterations 10 -DelaySeconds 1
                Assert-MockCalled -CommandName Start-Sleep -Exactly 10 -Scope It
            }

            it 'Sleeps for correct number of milliseconds' {
                Test-AzRegionLatency -Region westus -Iterations 10 -DelayMilliseconds 1
                Assert-MockCalled -CommandName Start-Sleep -Exactly 10 -Scope It
            }
        }
    }
}
