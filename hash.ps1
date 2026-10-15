[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned

Write-Host "Installing required module..."
    Install-Script -Name Get-WindowsAutopilotInfo -Force

Write-Host "Uploading device to Autopilot..."
    Get-WindowsAutopilotInfo -Online