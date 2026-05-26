@echo off
echo ===================================================
echo KHOI DONG HE THONG PHAN TAN CHANDY-LAMPORT
echo ===================================================

echo [1/3] Dang bat Node A (Master - Port 8081)...
start powershell -NoExit -Command ".\mvnw spring-boot:run '-Dspring-boot.run.jvmArguments=-Dserver.port=8081 -Dfile.encoding=UTF-8'"

echo [2/3] Dang bat Node B (Worker - Port 8082)...
start powershell -NoExit -Command ".\mvnw spring-boot:run '-Dspring-boot.run.jvmArguments=-Dserver.port=8082 -Dfile.encoding=UTF-8'"

echo [3/3] Dang bat Node C (Worker - Port 8083)...
start powershell -NoExit -Command ".\mvnw spring-boot:run '-Dspring-boot.run.jvmArguments=-Dserver.port=8083 -Dfile.encoding=UTF-8'"

echo.
echo HOAN TAT! 3 cua so PowerShell da duoc mo de chay 3 Node.
echo Vui long doi khoang 15-30 giay de Spring Boot khoi dong xong, sau do F5 lai trang Web de test.
pause