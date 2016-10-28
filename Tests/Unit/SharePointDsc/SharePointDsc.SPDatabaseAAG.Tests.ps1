﻿[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string] 
    $SharePointCmdletModule = (Join-Path -Path $PSScriptRoot `
                                         -ChildPath "..\Stubs\SharePoint\15.0.4805.1000\Microsoft.SharePoint.PowerShell.psm1" `
                                         -Resolve)
)

Import-Module -Name (Join-Path -Path $PSScriptRoot `
                                -ChildPath "..\SharePointDsc.TestHarness.psm1" `
                                -Resolve)

$Global:SPDscHelper = New-SPDscUnitTestHelper -SharePointStubModule $SharePointCmdletModule `
                                              -DscResource "SPDatabaseAAG"

Describe -Name $Global:SPDscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:SPDscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:SPDscHelper.InitializeScript -NoNewScope

        # Mocks for all contexts   
        Mock -CommandName Add-DatabaseToAvailabilityGroup -MockWith { }
        Mock -CommandName Remove-DatabaseFromAvailabilityGroup -MockWith { }

        # Test contexts
        Context -Name "The database is not in an availability group, but should be" -Fixture {
            $testParams = @{
                DatabaseName = "SampleDatabase"
                AGName = "AGName"
                Ensure = "Present"
            }

            Mock -CommandName Get-SPDatabase -MockWith {
                return @(
                    @{
                        Name = $testParams.DatabaseName
                        AvailabilityGroup = $null
                    }
                )
            }

            It "Should return the current values from the get method" {
                Get-TargetResource @testParams | Should Not BeNullOrEmpty
            }

            It "Should return false from the test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should call the add cmdlet in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Add-DatabaseToAvailabilityGroup
            }
        }

        Context -Name "The databases are not in an availability group, but should be" -Fixture {
            $testParams = @{
                DatabaseName = "Sample"
                AGName = "AGName"
                Ensure = "Present"
            }

            Mock -CommandName Get-SPDatabase -MockWith {
                return @(
                    @{
                        Name = "SampleDatabase1"
                        AvailabilityGroup = $null
                    },
                    @{
                        Name = "SampleDatabase2"
                        AvailabilityGroup = $null
                    }
                )
            }

            It "Should return the current values from the get method" {
                Get-TargetResource @testParams | Should Not BeNullOrEmpty
            }

            It "Should return false from the test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should call the add cmdlet in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Add-DatabaseToAvailabilityGroup
            }
        }

        Context -Name "Single database is not in an availability group, but should be" -Fixture {
            $testParams = @{
                DatabaseName = "Sample"
                AGName = "AGName"
                Ensure = "Present"
            }

            Mock -CommandName Get-SPDatabase -MockWith {
                return @(
                    @{
                        Name = "SampleDatabase1"
                        AvailabilityGroup = $null
                    },
                    @{
                        Name = "SampleDatabase2"
                        AvailabilityGroup = @{
                            Name = $testParams.AGName
                        }
                    }
                )
            }

            It "Should return the current values from the get method" {
                Get-TargetResource @testParams | Should Not BeNullOrEmpty
            }

            It "Should return false from the test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should call the add cmdlet in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Add-DatabaseToAvailabilityGroup
            }
        }

        Context -Name "The database is not in the availability group and should not be" -Fixture {
            $testParams = @{
                DatabaseName = "SampleDatabase"
                AGName = "AGName"
                Ensure = "Absent"
            }
            
            Mock -CommandName Get-SPDatabase -MockWith {
                return @(
                    @{
                        Name = $testParams.DatabaseName
                        AvailabilityGroup = $null
                    }
                )
            }

            It "Should return the current values from the get method" {
                Get-TargetResource @testParams | Should Not BeNullOrEmpty
            }

            It "Should return true from the test method" {
                Test-TargetResource @testParams | Should Be $true
            }
        }

        Context -Name "The databases are not in the availability group and should not be" -Fixture {
            $testParams = @{
                DatabaseName = "SampleDatabase"
                AGName = "AGName"
                Ensure = "Absent"
            }
            
            Mock -CommandName Get-SPDatabase -MockWith {
                return @(
                    @{
                        Name = "SampleDatabase1"
                        AvailabilityGroup = $null
                    },
                    @{
                        Name = "SampleDatabase2"
                        AvailabilityGroup = $null
                    }
                )
            }

            It "Should return the current values from the get method" {
                Get-TargetResource @testParams | Should Not BeNullOrEmpty
            }

            It "Should return true from the test method" {
                Test-TargetResource @testParams | Should Be $true
            }
        }

        Context -Name "The database is in the correct availability group and should be" -Fixture {
            $testParams = @{
                DatabaseName = "SampleDatabase"
                AGName = "AGName"
                Ensure = "Present"
            }
            
            Mock -CommandName Get-SPDatabase -MockWith {
                return @(
                    @{
                        Name = $testParams.DatabaseName
                        AvailabilityGroup = @{
                            Name = $testParams.AGName
                        }
                    }
                )
            }

            It "Should return the current values from the get method" {
                Get-TargetResource @testParams | Should Not BeNullOrEmpty
            }

            It "Should return true from the test method" {
                Test-TargetResource @testParams | Should Be $true
            }
        }

        Context -Name "The databases are in the correct availability group and should be" -Fixture {
            $testParams = @{
                DatabaseName = "SampleDatabase"
                AGName = "AGName"
                Ensure = "Present"
            }
            
            Mock -CommandName Get-SPDatabase -MockWith {
                return @(
                    @{
                        Name = "SampleDatabase1"
                        AvailabilityGroup = @{
                            Name = $testParams.AGName
                        }
                    },
                    @{
                        Name = "SampleDatabase2"
                        AvailabilityGroup = @{
                            Name = $testParams.AGName
                        }
                    }
                )
            }

            It "Should return the current values from the get method" {
                Get-TargetResource @testParams | Should Not BeNullOrEmpty
            }

            It "Should return true from the test method" {
                Test-TargetResource @testParams | Should Be $true
            }
        }

        Context -Name "The database is in an availability group and should not be" -Fixture {
            $testParams = @{
                DatabaseName = "SampleDatabase"
                AGName = "AGName"
                Ensure = "Absent"
            }
            
            Mock -CommandName Get-SPDatabase -MockWith {
                return @(
                    @{
                        Name = $testParams.DatabaseName
                        AvailabilityGroup = @{
                            Name = $testParams.AGName
                        }
                    }
                )
            }

            It "Should return the current values from the get method" {
                Get-TargetResource @testParams | Should Not BeNullOrEmpty
            }

            It "Should return false from the test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should call the remove cmdlet in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Remove-DatabaseFromAvailabilityGroup
            }
        }

        Context -Name "The databases are in an availability group and should not be" -Fixture {
            $testParams = @{
                DatabaseName = "SampleDatabase"
                AGName = "AGName"
                Ensure = "Absent"
            }
            
            Mock -CommandName Get-SPDatabase -MockWith {
                return @(
                    @{
                        Name = "SampleDatabase1"
                        AvailabilityGroup = @{
                            Name = $testParams.AGName
                        }
                    },
                    @{
                        Name = "SampleDatabase2"
                        AvailabilityGroup = @{
                            Name = $testParams.AGName
                        }
                    }
                )
            }

            It "Should return the current values from the get method" {
                Get-TargetResource @testParams | Should Not BeNullOrEmpty
            }

            It "Should return false from the test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should call the remove cmdlet in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Remove-DatabaseFromAvailabilityGroup
            }
        }

        Context -Name "Single database is in an availability group and should not be" -Fixture {
            $testParams = @{
                DatabaseName = "SampleDatabase"
                AGName = "AGName"
                Ensure = "Absent"
            }
            
            Mock -CommandName Get-SPDatabase -MockWith {
                return @(
                    @{
                        Name = "SampleDatabase1"
                        AvailabilityGroup = @{
                            Name = $null
                        }
                    },
                    @{
                        Name = "SampleDatabase2"
                        AvailabilityGroup = @{
                            Name = $testParams.AGName
                        }
                    }
                )
            }

            It "Should return the current values from the get method" {
                Get-TargetResource @testParams | Should Not BeNullOrEmpty
            }

            It "Should return false from the test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should call the remove cmdlet in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Remove-DatabaseFromAvailabilityGroup
            }
        }

        Context -Name "The database is in the wrong availability group" -Fixture {
            $testParams = @{
                DatabaseName = "SampleDatabase"
                AGName = "AGName"
                Ensure = "Present"
            }
            
            Mock -CommandName Get-SPDatabase -MockWith {
                return @(
                    @{
                        Name = $testParams.DatabaseName
                        AvailabilityGroup = @{
                            Name = "WrongAAG"
                        }
                    }
                )
            }

            It "Should return the current values from the get method" {
                Get-TargetResource @testParams | Should Not BeNullOrEmpty
            }

            It "Should return false from the test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should call the remove and add cmdlets in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Remove-DatabaseFromAvailabilityGroup
                Assert-MockCalled Add-DatabaseToAvailabilityGroup
            }
        }

        Context -Name "Single database is in the wrong availability group" -Fixture {
            $testParams = @{
                DatabaseName = "SampleDatabase"
                AGName = "AGName"
                Ensure = "Present"
            }
            
            Mock -CommandName Get-SPDatabase -MockWith {
                return @(
                    @{
                        Name = $testParams.DatabaseName
                        AvailabilityGroup = @{
                            Name = $testParams.AGName
                        }
                    },
                    @{
                        Name = $testParams.DatabaseName
                        AvailabilityGroup = @{
                            Name = "WrongAAG"
                        }
                    }
                )
            }

            It "Should return the current values from the get method" {
                Get-TargetResource @testParams | Should Not BeNullOrEmpty
            }

            It "Should return false from the test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should call the remove and add cmdlets in the set method" {
                Set-TargetResource @testParams
                Assert-MockCalled Remove-DatabaseFromAvailabilityGroup
                Assert-MockCalled Add-DatabaseToAvailabilityGroup
            }
        }

        Context -Name "Specified database is not found" -Fixture {
            $testParams = @{
                DatabaseName = "SampleDatabase"
                AGName = "AGName"
                Ensure = "Present"
            }
            
            Mock -CommandName Get-SPDatabase -MockWith {
                return @(
                    @{
                        Name = "WrongDatabase"
                        AvailabilityGroup = @{
                            Name = $testParams.AGName
                        }
                    }
                )
            }

            It "Should return Ensure='Not Found' from the get method" {
                (Get-TargetResource @testParams).Ensure | Should Be "Not Found"
            }

            It "Should return false from the test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Should throw an exception in the set method" {
                { Set-TargetResource @testParams } | Should Throw "Specified database(s) not found."
            }
        }        
    }
}

Invoke-Command -ScriptBlock $Global:SPDscHelper.CleanupScript -NoNewScope
