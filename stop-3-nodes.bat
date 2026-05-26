@echo off
echo ===================================================
echo TIEN TRINH TAT 3 NODE GAME SCORE SYNC (8081, 8082, 8083)
echo ===================================================

echo [1/3] Dang quet va giai phong Cong 8081 (Node A)...
powershell -Command "$tcp = Get-NetTCPConnection -LocalPort 8081 -ErrorAction SilentlyContinue; if ($tcp) { Stop-Process -Id $tcp.OwningProcess -Force; Write-Host '  - Da diet Node A thanh cong!' -ForegroundColor Green } else { Write-Host '  - Node A khong hoat dong.' -ForegroundColor DarkGray }"

echo [2/3] Dang quet va giai phong Cong 8082 (Node B)...
powershell -Command "$tcp = Get-NetTCPConnection -LocalPort 8082 -ErrorAction SilentlyContinue; if ($tcp) { Stop-Process -Id $tcp.OwningProcess -Force; Write-Host '  - Da diet Node B thanh cong!' -ForegroundColor Green } else { Write-Host '  - Node B khong hoat dong.' -ForegroundColor DarkGray }"

echo [3/3] Dang quet va giai phong Cong 8083 (Node C)...
powershell -Command "$tcp = Get-NetTCPConnection -LocalPort 8083 -ErrorAction SilentlyContinue; if ($tcp) { Stop-Process -Id $tcp.OwningProcess -Force; Write-Host '  - Da diet Node C thanh cong!' -ForegroundColor Green } else { Write-Host '  - Node C khong hoat dong.' -ForegroundColor DarkGray }"

echo.
echo ===================================================
echo HOAN TAT! Ca 3 Node da duoc dong va giai phong cong mang.
echo ===================================================
pause