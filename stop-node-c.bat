@echo off
echo ===================================================
echo DANG QUET VA TAT NODE C (PORT 8083)...
echo ===================================================

powershell -Command "$port = 8083; $tcp = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue; if ($tcp) { Stop-Process -Id $tcp.OwningProcess -Force; Write-Host '- Da diet tien trinh Node C thanh cong!' -ForegroundColor Green } else { Write-Host '- Khong tim thay Node C nao dang chay o cong nay.' -ForegroundColor Yellow }"

echo ===================================================
pause