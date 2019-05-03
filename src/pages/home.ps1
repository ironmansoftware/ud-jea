New-UDPage -Name "Home" -Icon cog -Content {

    New-UDGrid -Title "Session Configurations" -Id "SessionConfigs" -Headers @("Name", "Permission", "Enable", "Delete") -Properties @("Name", "Permission", "Enable", "Delete") -Endpoint {
        Get-PSSessionConfiguration | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.Name 
                Permission = $_.Permission
                Enable = $_.Enabled
                Delete = (New-UDButton -Icon trash -Text "Delete" -OnClick {
                    $ConfigPath = Join-Path $Paths.SessionConfigs "$($_.Name).pssc"
                    Unregister-PSSessionConfiguration -Name $_.Name
                    Remove-Item $ConfigPath -Force 
                    Sync-UDElement -Id 'SessionConfigs'
                }) 
            } 
        } | Out-UDGridData
    }

    New-UDMuButton -Icon (New-UDMuIcon -Icon plus) -Text "New" -Variant contained -OnClick {
        Show-UDModal -Header {
            New-UDHeading -Text "New Session Configuration" -Size 2
        } -Content {
            New-UDInput -Title "" -Endpoint {
                param(
                    [Parameter(Mandatory)]$Name, 
                    $RoleDefinitions
                )

                $ConfigPath = Join-Path $Paths.SessionConfigs "$name.pssc"

                $Parameters = @{
                    Path = $ConfigPath 
                    Author = $User
                    SessionType = "RestrictedRemoteServer"
                    RunAsVirtualAccount = $true 
                    TranscriptDirectory = $Paths.Transcript
                    RoleDefinitions = $RoleDefinitions
                }

                New-PSSessionConfigurationFile @Parameters

                Register-PSSessionConfiguration -Name $Name -Path $ConfigPath

                Sync-UDElement -Id 'SessionConfigs'
            } -Validate
        }
    }

    New-UDGrid -Title "Role Capabilties" -Id 'RoleCapabilities' -Headers @("Name", "Delete") -Properties @("Name", "Delete") -Endpoint {
        Get-ChildItem $Paths.RoleCapabilities | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.Name.Replace(".psrc", "")
                Delete = (New-UDButton -Icon trash -Text "Delete" -OnClick {
                    Remove-Item $_.FullName 
                    Sync-UDElement -Id 'RoleCapabilities'
                }) 
            }       
        } | Out-UDGridData
    }

    New-UDMuButton -Icon (New-UDMuIcon -Icon plus) -Text "New" -Variant contained -OnClick {

        Show-UDModal -Header {
            New-UDHeading -Text "New Role Capability" -Size 3
        } -Content {
            New-UDInput -Title "" -Endpoint {
                param(
                    [Parameter(Mandatory)]
                    $Name, 
                    $ModulesToImport,
                    $VisibleAliases,
                    $VisibleCmdlets,
                    $VisibleFunctions,
                    $VisibleExternalCommands,
                    $VisibleProviders,
                    $ScriptsToProcess
                )
        
                $ConfigPath = Join-Path $Paths.RoleCapabilities "$Name.psrc"
        
                $Parameters = @{
                    ModulesToImport = $ModulesToImport
                    VisibleAliases = $VisibleAliases
                    VisibleCmdlets = $VisibleCmdlets
                    VisibleFunctions = $VisibleFunctions
                    VisibleExternalCommands = $VisibleExternalCommands
                    VisibleProviders = $VisibleProviders
                    ScriptsToProcess = $ScriptsToProcess
                }
        
                New-PSRoleCapabilityFile -Path $ConfigPath @Parameters

                Sync-UDElement -Id 'RoleCapabilities'
            } -Validate
        }

        
    }

} #-AuthorizationPolicy "Administrators"