param(
    [string]$Godot = $env:GODOT_EXECUTABLE,
    [switch]$TestOnly,
    [switch]$UnsignedCheck
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
if (-not $Godot) {
    $machine = Join-Path $repo '.local/machine.json'
    if (Test-Path -LiteralPath $machine) {
        $Godot = (Get-Content -LiteralPath $machine -Raw | ConvertFrom-Json).godotExecutable
    }
}
if (-not $Godot -or -not (Test-Path -LiteralPath $Godot)) {
    throw 'Set GODOT_EXECUTABLE or pass -Godot with the Godot 4.7.2 console executable path.'
}
$project = Join-Path $repo 'game'
if (-not $UnsignedCheck -and -not $TestOnly -and -not $env:GODOT_ANDROID_KEYSTORE_DEBUG_PATH) {
    $machinePath = Join-Path $repo '.local/machine.json'
    if (Test-Path -LiteralPath $machinePath) {
        $localConfig = Get-Content -LiteralPath $machinePath -Raw | ConvertFrom-Json
        if ($localConfig.androidSigningConfig) {
            $signing = Get-Content -LiteralPath $localConfig.androidSigningConfig -Raw | ConvertFrom-Json
            $env:GODOT_ANDROID_KEYSTORE_DEBUG_PATH = $signing.path
            $env:GODOT_ANDROID_KEYSTORE_DEBUG_USER = $signing.alias
            $env:GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD = $signing.password
        }
    }
}
& $Godot --headless --path $project --editor --import --quit
if ($LASTEXITCODE -ne 0) { throw 'Godot import failed.' }
& $Godot --headless --path $project --script res://tests/test_game.gd
if ($LASTEXITCODE -ne 0) { throw 'Game tests failed.' }
& $Godot --headless --path $project --script res://tests/test_daily.gd
if ($LASTEXITCODE -ne 0) { throw 'Daily challenge tests failed.' }
& $Godot --headless --path $project --script res://tests/test_refill.gd
if ($LASTEXITCODE -ne 0) { throw 'Refill regression/benchmark failed.' }
if ($TestOnly) { exit 0 }
$template = Join-Path $repo '.local/templates/android_debug.apk'
if (-not (Test-Path -LiteralPath $template)) {
    throw 'Missing Android template. See docs/android.md; extract the official 4.7.2 template into .local/templates/.'
}
$outputDir = Join-Path $repo 'exports'
New-Item -ItemType Directory -Force $outputDir | Out-Null
$apk = Join-Path $outputDir 'WarOfWords-0.1.8-android.apk'
if ($UnsignedCheck) {
    # Validate export without signing the artifact with this machine's new debug key.
    $apk = Join-Path $repo '.local/WarOfWords-0.1.8-UNSIGNED-CHECK.apk'
    $presetPath = Join-Path $project 'export_presets.cfg'
    $presetBytes = [IO.File]::ReadAllBytes($presetPath)
    $presetText = [Text.Encoding]::UTF8.GetString($presetBytes)
    if (-not $presetText.Contains('package/signed=true')) { throw 'Expected signed Android preset.' }
    try {
        [IO.File]::WriteAllText($presetPath, $presetText.Replace('package/signed=true', 'package/signed=false'))
        & $Godot --headless --path $project --export-debug Android $apk
        if ($LASTEXITCODE -ne 0) { throw 'Unsigned Android export failed.' }
    } finally {
        [IO.File]::WriteAllBytes($presetPath, $presetBytes)
    }
} else {
    $key = $env:GODOT_ANDROID_KEYSTORE_DEBUG_PATH
    if (-not $key) {
        throw 'Set GODOT_ANDROID_KEYSTORE_DEBUG_PATH to the existing signing key, or use -UnsignedCheck to validate export without it. See docs/android.md.'
    }
    if (-not (Test-Path -LiteralPath $key)) { throw 'Signing key does not exist.' }
    & $Godot --headless --path $project --export-debug Android $apk
    if ($LASTEXITCODE -ne 0) { throw 'Android export failed.' }
}
$hash = (Get-FileHash -LiteralPath $apk -Algorithm SHA256).Hash.ToLowerInvariant()
[IO.File]::WriteAllText($apk + '.sha256', $hash + '  ' + [IO.Path]::GetFileName($apk) + "`n")
Write-Output "APK: $apk"
Write-Output "SHA256: $hash"
