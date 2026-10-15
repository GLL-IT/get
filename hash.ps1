Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    Write-Host "Configuring PowerShell Gallery..." -ForegroundColor Cyan
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted -ErrorAction SilentlyContinue

    Write-Host "Installing NuGet provider..." -ForegroundColor Cyan
    Install-PackageProvider -Name NuGet -Force -ErrorAction SilentlyContinue

    Write-Host "Installing Get-WindowsAutopilotInfo..." -ForegroundColor Cyan
    Install-Script -Name Get-WindowsAutopilotInfo -Force -Confirm:$false

    Write-Host "Uploading device to Autopilot..." -ForegroundColor Cyan
    Get-WindowsAutopilotInfo -Online

    Write-Host ""
    Write-Host "Autopilot upload completed successfully." -ForegroundColor Green
}
catch {
    Write-Host ""
    Write-Host "Autopilot upload failed." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}

Pause