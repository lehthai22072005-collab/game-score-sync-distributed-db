@echo off
echo ===================================================
echo TIEN TRINH TAT 3 NODE GAME SCORE SYNC (8081, 8082, 8083)
echo ===================================================

echo [1/3] Dang quet va giai phong Cong 8081 (Node A)...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8081 ^| findstr LISTENING') do (
    taskkill /f /pid %%a
    echo - Da tat Node A (PID: %%a)
)

echo [2/3] Dang quet va giai phong Cong 8082 (Node B)...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8082 ^| findstr LISTENING') do (
    taskkill /f /pid %%a
    echo - Da tat Node B (PID: %%a)
)

echo [3/3] Dang quet va giai phong Cong 8083 (Node C)...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8083 ^| findstr LISTENING') do (
    taskkill /f /pid %%a
    echo - Da tat Node C (PID: %%a)
)

echo.
echo ===================================================
echo HOAN TAT! Ca 3 Node da duoc dong va giai phong cong mang.
echo ===================================================
pause