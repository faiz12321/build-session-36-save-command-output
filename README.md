# Save command output without replacing old files

Windows practice for PowerShell 7, with one command that explicitly invokes Windows PowerShell 5.1. Both must already be installed. No installation or administrator action is shown.

Save setup36.ps1 and test_setup36.ps1 in a new empty lesson folder. Run from PowerShell 7 in that folder:

    ./setup36.ps1
    cmd /d /c "dir /b sample" | Out-File -LiteralPath sample\listing.txt -Encoding utf8 -NoClobber
    Get-Content -LiteralPath sample\listing.txt -Encoding utf8
    ./test_setup36.ps1

Use lesson.html for the complete recorded sequence. Do not use > or >> on valuable files. > replaces its target; >> appends and can duplicate content. Out-File -NoClobber refuses an existing output. Setup refuses an existing sample path and exclusively creates fictional input. Do not delete old data to force a retry. Partial new setup/output can remain after an unrelated error.

## Scope and limits

Normal output and error streams are separate. A created capture file does not mean the producer succeeded. The exercises print the native exit code for a failing cmd type command. Error wording depends on the operating-system language and program. Reports can expose paths and private command errors.

The directory listing may include its own output filename because the output is inside the folder being listed. It is a recorded example, not a stable folder snapshot.

Windows PowerShell 5.1 Out-File defaults to UTF-16LE. PowerShell 7 Out-File defaults to UTF-8 without a BOM. This claim is about Out-File, not every text cmdlet or native redirection. PowerShell 7.4 changed native stdout redirection behavior; these captures explicitly pipe text to Out-File.

The conversion knows the hello fixture's source encoding. Get-Content and Out-File can normalize line endings/final newlines and format objects. They are not a binary-safe, lossless general converter or encoding detector. Keep original files and compare the content needed for your use.

Eight temporary-fixture checks cover new/repeat setup, nested unrelated bytes/mtime, NoClobber refusal, source bytes and a known text conversion. The tests clean up only their own unique temporary test folder. These checks do not prove all filesystems or concurrent changes. Code is MIT licensed; see LICENSE. PowerShell and Windows are separate products and are not included. No warranty.

## Sources

- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/out-file
- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_character_encoding
- https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_redirection
