@echo off
echo ===================================================
echo DANG QUET VA TAT NODE A (PORT 8081)...
echo ===================================================

powershell -Command "$port = 8081; $tcp = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue; if ($tcp) { Stop-Process -Id $tcp.OwningProcess -Force; Write-Host '- Da diet tien trinh Node A thanh cong!' -ForegroundColor Green } else { Write-Host '- Khong tim thay Node A nao dang chay o cong nay.' -ForegroundColor Yellow }"

echo ===================================================
pause