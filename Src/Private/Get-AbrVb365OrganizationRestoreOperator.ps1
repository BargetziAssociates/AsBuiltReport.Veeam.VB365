function Get-AbrVb365OrganizationRestoreOperator {
    <#
    .SYNOPSIS
    Used by As Built Report to retrieve Veeam VB365 Office365 Restore Operator Settings
    .DESCRIPTION
        Documents the configuration of Veeam VB365 in Word/HTML/Text formats using PScribo.
    .NOTES
        Version:        0.3.0
        Author:         Jonathan Colon
        Twitter:        @jcolonfzenpr
        Github:         rebelinux
        Credits:        Iain Brighton (@iainbrighton) - PScribo module

    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.Veeam.VB365
    #>
    [CmdletBinding()]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true
        )]
        [ValidateNotNullOrEmpty()]
        [String] $Organization
    )

    begin {
        Write-PScriboMessage "Organizations InfoLevel set at $($InfoLevel.Infrastructure.Organization)."
    }

    process {
        try {
            $Organizations = Get-VBOOrganization -Name $Organization
            $script:RestoreOperators = try { Get-VBORbacRole -Organization $Organizations | Sort-Object -Property Name} catch { Out-Null }
            if (($InfoLevel.Infrastructure.Organization -gt 0) -and ($RestoreOperators)) {
                Write-PScriboMessage "Collecting Veeam VB365 Office365 Restore Operators Settings."
                Section -Style Heading4 'Restore Operators' {
                    foreach ($RestoreOperator in $RestoreOperators) {
                        Section -ExcludeFromTOC -Style NOTOCHeading5 "$($RestoreOperator.Name)" {
                            $RestoreOperatorInfo = @()

                            $inObj = [ordered] @{
                                'Role Type' = $RestoreOperator.RoleType
                                'Operators' = $RestoreOperator.Operators.UserName
                                'Selected Items' = $RestoreOperator.SelectedItems.UserName
                                'Excluded Items' = $RestoreOperator.ExcludedItems.UserName
                                'Description' = $RestoreOperator.Description
                            }

                            $RestoreOperatorInfo += [PSCustomObject]$InObj

                            $TableParams = @{
                                Name = "Restore Operator - $($RestoreOperator.Name)"
                                List = $true
                                ColumnWidths = 40, 60
                            }
                            if ($Report.ShowTableCaptions) {
                                $TableParams['Caption'] = "- $($TableParams.Name)"
                            }

                            $RestoreOperatorInfo | Table @TableParams

                        }
                    }
                }
            }
        } catch {
            Write-PScriboMessage -IsWarning "VB365 Office365 Restore Operators Settings Section: $($_.Exception.Message)"
        }
    }

    end {}
}