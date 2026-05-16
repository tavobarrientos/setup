if ($host.Name -eq 'ConsoleHost')
{
    Import-Module PSReadLine
        
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows

    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

    Set-PSReadLineOption -ShowToolTips
}

oh-my-posh init pwsh --config C:\Users\tavob\OneDrive\omp\tavobarrientos.omp.json | Invoke-Expression

# Forzar emisión de CWD para Windows Terminal
function Update-Cwd {
    $cwd = $PWD.ProviderPath
    [Console]::Write("$([char]27)]9;9;`"$cwd`"$([char]27)\")
}

$global:__originalPrompt = $function:prompt
function prompt {
    Update-Cwd
    & $global:__originalPrompt
}

# Import-Module -Name Terminal-Icons


function touchFile($fileName) {
    # Check if the file exists
    if (Test-Path $fileName) {
        # Update the last modified time to now
        (Get-Item $fileName).LastWriteTime = Get-Date
    } else {
        # Create a new file
        New-Item -Path $fileName -ItemType File
    }
}

function goToSource() {
    if (Test-Path "c:\src") {
        Set-Location -Path "c:\src"
    } elseif (Test-Path "e:\src") {
        Set-Location -Path "e:\src"
    } else {
        Write-Host "Source code directory not found."
    }
}

set-alias -name Touch -value touchFile
set-alias -name src -value goToSource

