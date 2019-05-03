$DataPath = Join-Path ([Environment]::GetFolderPath('CommonApplicationData')) "UDJea"

if (-not (Test-Path $DataPath)) {
    New-Item $DataPath -ItemType Directory | Out-Null
}

$SessionConfigPath = Join-Path $DataPath "SessionConfiguration"

if (-not (Test-Path $SessionConfigPath)) {
    New-Item $SessionConfigPath -ItemType Directory | Out-Null
}

$TranscriptPath = Join-Path $DataPath "Transcripts"

if (-not (Test-Path $TranscriptPath)) {
    New-Item $TranscriptPath -ItemType Directory | Out-Null
}

$RoleCapabilitiesPath = Join-Path $PSScriptRoot "RoleCapabilties"

if (-not (Test-Path $RoleCapabilitiesPath)) {
    New-Item $RoleCapabilitiesPath -ItemType Directory | Out-Null
}

$Paths = @{
    RoleCapabilities = $RoleCapabilitiesPath
    Transcript = $TranscriptPath
    SessionConfigs = $SessionConfigPath
    Data = $DataPath
    Root = $PSScriptRoot
}

function Start-UDJea {
    param($Port = 10000)

    $Pages = Get-ChildItem (Join-Path $PSScriptRoot "pages") | ForEach-Object {
        . $_.FullName
    }

    $Root = $PSScriptRoot 
    $EndpointInit = New-UDEndpointInitialization -Variable @("Paths")

    $LoginPage = New-UDLoginPage -AuthenticationMethod @(
        New-UDAuthenticationMethod -Endpoint {
            param([pscredential]$Credential)

            New-UDAuthenticationResult -Success -UserName $Credential.UserName
        }
    )

    $Parameters = @{
        Title = "JEA"
        Pages = $Pages 
        EndpointInitialization = $EndpointInit
        LoginPage = $LoginPage
    }
    
    $Dashboard = New-UDDashboard @Parameters
    
    Start-UDDashboard -Dashboard $Dashboard -Port $Port -AllowHttpForLogin
}