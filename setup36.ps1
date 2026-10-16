# Run in PowerShell 7 from a new empty lesson folder.
# Creates only a new sample folder. Existing sample paths are refused.
$ErrorActionPreference = 'Stop'
$sample = Join-Path $PSScriptRoot 'sample'
try {
    New-Item -ItemType Directory -Path $sample -ErrorAction Stop | Out-Null
} catch {
    Write-Output 'Stopped: sample already exists or could not be created. Nothing there was replaced.'
    exit 1
}
function Write-NewText([string]$Name, [string]$Text) {
    $path = Join-Path $sample $Name
    $bytes = [Text.Encoding]::UTF8.GetBytes($Text)
    $stream = [IO.File]::Open($path, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write)
    try { $stream.Write($bytes, 0, $bytes.Length) } finally { $stream.Dispose() }
}
Write-NewText 'data.csv' "item,value`r`nExample,12`r`n"
Write-NewText 'notes.txt' "Fictional practice notes.`r`n"
Write-Output 'Created sample/data.csv and sample/notes.txt with fictional content.'
Write-Output 'Existing sample paths are refused. Use a different new lesson folder for fresh practice.'
