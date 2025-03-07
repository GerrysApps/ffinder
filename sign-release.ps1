Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted

$cert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert
$cert = Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert | Where-Object {$_.FriendlyName -eq "Gerry's Code Signing Cert"}

Set-AuthenticodeSignature -FilePath "C:\Users\gerry\Documents\Github\ffinder\build\windows\x64\runner\Release\ffinder.exe" -Certificate $cert

