@echo off
echo ===================================================
echo KHOI DONG NODE A (PORT 8081)
echo ===================================================
start powershell -NoExit -Command ".\mvnw spring-boot:run '-Dspring-boot.run.jvmArguments=-Dserver.port=8081 -Dfile.encoding=UTF-8'"
echo Da mo cua so chay Node A. Vui long doi giay lat...