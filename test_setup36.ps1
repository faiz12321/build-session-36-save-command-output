# Small temporary-fixture checks. Not proof for all filesystems or concurrent changes.
$ErrorActionPreference = 'Stop'
$root = Join-Path ([IO.Path]::GetTempPath()) ('lesson36-test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $root | Out-Null
$passed = 0
function Assert([bool]$Condition, [string]$Label) {
    if (-not $Condition) { throw $Label }
    $script:passed++
    Write-Output ('PASS: ' + $Label)
}
try {
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'setup36.ps1') -Destination $root
    $setup = Join-Path $root 'setup36.ps1'
    & pwsh -NoProfile -File $setup | Out-Null
    Assert ($LASTEXITCODE -eq 0) 'new setup succeeds'
    $sample = Join-Path $root 'sample'
    Assert ((Get-ChildItem -LiteralPath $sample).Count -eq 2) 'only two fictional input files created'
    $keep = Join-Path $sample 'nested/keep.txt'
    New-Item -ItemType Directory (Split-Path $keep) | Out-Null
    [IO.File]::WriteAllText($keep, 'KEEP')
    $before = (Get-FileHash -LiteralPath $keep -Algorithm SHA256).Hash
    $mtime = [IO.File]::GetLastWriteTimeUtc($keep).Ticks
    & pwsh -NoProfile -File $setup | Out-Null
    Assert ($LASTEXITCODE -eq 1) 'repeat setup refuses'
    Assert (((Get-FileHash -LiteralPath $keep -Algorithm SHA256).Hash -eq $before) -and ([IO.File]::GetLastWriteTimeUtc($keep).Ticks -eq $mtime)) 'nested unrelated bytes and modification time survive'
    $target = Join-Path $root 'existing.txt'
    [IO.File]::WriteAllText($target, 'KEEP')
    $caught = $false
    try { 'replacement' | Out-File -LiteralPath $target -NoClobber -Encoding utf8 } catch { $caught = $true }
    Assert ($caught -and [IO.File]::ReadAllText($target) -eq 'KEEP') 'Out-File NoClobber refuses an existing output'
    $source = Join-Path $root 'utf16.txt'
    $fixed = Join-Path $root 'utf8.txt'
    [IO.File]::WriteAllText($source, "hello`r`n", [Text.Encoding]::Unicode)
    $sourceHash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
    Get-Content -LiteralPath $source -Encoding Unicode | Out-File -LiteralPath $fixed -Encoding utf8NoBOM -NoClobber
    Assert (([IO.File]::ReadAllText($source, [Text.Encoding]::Unicode)) -eq ([IO.File]::ReadAllText($fixed, [Text.Encoding]::UTF8))) 'known hello fixture has equal decoded text after conversion'
    Assert (((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash) -eq $sourceHash) 'conversion leaves source bytes unchanged'
    $bytes = [IO.File]::ReadAllBytes($fixed)
    Assert (([BitConverter]::ToString($bytes[0..3])) -eq '68-65-6C-6C') 'converted hello fixture starts with UTF-8 bytes'
    Write-Output ("$passed limited fixture checks passed.")
} finally {
    Remove-Item -LiteralPath $root -Recurse -Force
}
