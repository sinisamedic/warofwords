param(
    [Parameter(Mandatory=$true)][string]$Apk,
    [Parameter(Mandatory=$true)][string]$Godot
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
Add-Type -AssemblyName System.IO.Compression.FileSystem
$target = Join-Path $repo ('.local/apk-dictionaries/' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force $target | Out-Null
$zip = [IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $Apk).Path)
try {
    $filterEntry = $zip.GetEntry('assets/data/blocked-words.json')
    if ($null -eq $filterEntry) { throw 'APK missing content filter' }
    [IO.Compression.ZipFileExtensions]::ExtractToFile($filterEntry, (Join-Path $target 'blocked-words.json'))
    foreach ($name in @('english', 'serbian', 'de', 'fr', 'es', 'it')) {
        $found = $false
        foreach ($suffix in @('.txt', '.txt.gz')) {
            $entry = $zip.GetEntry('assets/data/' + $name + $suffix)
            if ($null -ne $entry) {
                [IO.Compression.ZipFileExtensions]::ExtractToFile($entry, (Join-Path $target ($name + $suffix)))
                $found = $true
            }
        }
        if (-not $found) { throw "APK missing dictionary: $name" }
    }
} finally { $zip.Dispose() }
& $Godot --headless --path (Join-Path $repo 'game') --script res://tests/test_packaged_dictionaries.gd -- $target
if ($LASTEXITCODE -ne 0) { throw 'Packaged APK dictionary regression test failed.' }
