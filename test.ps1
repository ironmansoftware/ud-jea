ipmo (Join-Path $PSScriptRoot "src\ud-jea.psm1") -Force
Get-UDDashboard | Stop-UDDashboard
Start-UDJea -port 1000
start http://localhost:1000