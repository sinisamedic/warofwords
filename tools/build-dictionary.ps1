param([Parameter(Mandatory=$true)][string]$ScowlZip)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$expected = 'DC3435E1CB56F3394AEA91B5D2AB5D10D80C98BC7DD88C3FCCB7348F6AB913A0'
if ((Get-FileHash -LiteralPath $ScowlZip -Algorithm SHA256).Hash -ne $expected) {
    throw 'Expected the official SCOWL 2020.12.07 zip. See game/data/README.md.'
}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $ScowlZip))
$words = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
try {
    foreach ($entry in $zip.Entries) {
        if ($entry.FullName -notmatch '(^|/)final/(english|american)-words\.(10|20|35|40|50|55|60)$') { continue }
        $reader = [IO.StreamReader]::new($entry.Open())
        try {
            while (-not $reader.EndOfStream) {
                $word = $reader.ReadLine().Trim()
                if ($word -cmatch '^[a-z]{3,16}$') { [void]$words.Add($word) }
            }
        } finally { $reader.Dispose() }
    }
} finally { $zip.Dispose() }
$sorted = @($words | Sort-Object)
if ($sorted.Count -ne 76802) { throw "Unexpected dictionary count: $($sorted.Count)" }
$target = Join-Path $repo 'game/data/english.txt'
[IO.File]::WriteAllText($target, ($sorted -join "`n") + "`n", [Text.UTF8Encoding]::new($false))
Write-Output "Wrote $($sorted.Count) entries to $target"
