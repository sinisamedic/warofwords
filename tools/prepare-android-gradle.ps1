param([string]$TemplatesArchive)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
if (-not $TemplatesArchive) { $TemplatesArchive = Join-Path $repo '.local/downloads/godot-templates.tpz' }
$destination = Join-Path $repo 'game/android/build'
if (Test-Path -LiteralPath (Join-Path $destination 'build.gradle')) {
    Write-Output 'Android Gradle template already present.'
    exit 0
}
if (Test-Path -LiteralPath $destination) { throw 'Existing incomplete game/android/build. Inspect it before installing a template.' }
if (-not (Test-Path -LiteralPath $TemplatesArchive)) { throw 'Provide the official Godot 4.7.2 export templates archive with -TemplatesArchive.' }
Add-Type -AssemblyName System.IO.Compression.FileSystem
New-Item -ItemType Directory -Force (Join-Path $repo '.local') | Out-Null
$archive = [IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $TemplatesArchive))
$sourceZip = Join-Path $repo '.local/android_source.zip'
try {
    $entry = $archive.GetEntry('templates/android_source.zip')
    if (-not $entry) { throw 'Archive does not contain templates/android_source.zip.' }
    [IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $sourceZip, $true)
} finally { $archive.Dispose() }
[IO.Compression.ZipFile]::ExtractToDirectory($sourceZip, $destination)
[IO.File]::WriteAllText((Join-Path $repo 'game/android/.build_version'), '4.7.2.stable')
[IO.File]::WriteAllText((Join-Path $destination '.gdignore'), '')
Write-Output 'Installed local Android Gradle build template.'
