param(
    [string]$Godot = $env:GODOT_EXECUTABLE,
    [switch]$TestOnly
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
$apk = Join-Path $outputDir 'WarOfWords-0.1.7-android.apk'
& $Godot --headless --path $project --export-debug Android $apk
if ($LASTEXITCODE -ne 0) { throw 'Android export failed.' }
$hash = (Get-FileHash -LiteralPath $apk -Algorithm SHA256).Hash.ToLowerInvariant()
[IO.File]::WriteAllText($apk + '.sha256', $hash + '  ' + [IO.Path]::GetFileName($apk) + "`n")
Write-Output "APK: $apk"
Write-Output "SHA256: $hash"
