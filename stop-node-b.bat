@echo off
echo ===================================================
echo DANG QUET VA TAT NODE B (PORT 8082)...
echo ===================================================

powershell -Command "$port = 8082; $tcp = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue; if ($tcp) { Stop-Process -Id $tcp.OwningProcess -Force; Write-Host '- Da diệt tien trinh Node B thanh cong!' -ForegroundColor Green } else { Write-Host '- Khong tim thay Node B nao dang chay o cong nay.' -ForegroundColor Yellow }"

echo ===================================================
pause