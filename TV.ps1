Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

$ErrorActionPreference = 'Stop'

$installerUrl = 'https://get.teamviewer.com/6r2ents'
$assignmentId = '0001CoABChDmi2qAcUMR8ZW_y4vC5WDfEigIACAAAgAJAEPG5gQ3SUDZIAoQpYJnKfbPBha2ffpHaWMw-NB_K6djGkAsK3VPILqEKAKftcofqqY13Wl3VbUPsjtlxwPKV-HKI-AD8nVPW-ldWNNSSZmDKiu8dUFIuq5ExDu6p2nUDcW6IAEQ4s_koAM='
$workingDirectory = Join-Path ([System.IO.Path]::GetTempPath()) "TeamViewer-$([guid]::NewGuid().ToString('N'))"
$installerPath = Join-Path $workingDirectory 'TeamViewer_Host.msi'
$previousProgressPreference = $ProgressPreference

try {
    New-Item -Path $workingDirectory -ItemType Directory -Force -ErrorAction Stop | Out-Null
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing -ErrorAction Stop

    $installer = Get-Item -LiteralPath $installerPath -ErrorAction Stop
    if ($installer.Length -eq 0) {
        throw "The TeamViewer installer download from '$installerUrl' is empty."
    }

    $installArguments = @(
        '/i'
        "`"$installerPath`""
        '/qn'
        '/norestart'
        'CUSTOMCONFIGID=6r2ents'
        "ASSIGNMENTID=$assignmentId"
    ) -join ' '

    $process = Start-Process -FilePath 'msiexec.exe' `
        -ArgumentList $installArguments `
        -Wait `
        -PassThru `
        -ErrorAction Stop
}
catch {
    Write-Error "TeamViewer installation failed: $($_.Exception.Message)" -ErrorAction Continue
    exit 1
}
finally {
    $ProgressPreference = $previousProgressPreference
    if (Test-Path -LiteralPath $workingDirectory) {
        try {
            Remove-Item -LiteralPath $workingDirectory -Recurse -Force -ErrorAction Stop
        }
        catch {
            Write-Warning "Could not remove temporary TeamViewer deployment files at '$workingDirectory': $($_.Exception.Message)"
        }
    }
}

switch ($process.ExitCode) {
    0    { Write-Output 'Installation successful'; exit 0 }
    1618 { Write-Output 'Another installation is already in progress'; exit 1618 }
    3010 { Write-Output 'Installation successful; reboot required'; exit 3010 }
    1641 { Write-Output 'Installation successful; reboot initiated'; exit 1641 }
    default {
        throw "Installation failed with msiexec exit code $($process.ExitCode)."
    }
}