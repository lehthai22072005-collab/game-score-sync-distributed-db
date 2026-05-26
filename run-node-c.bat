@echo off
echo ===================================================
echo KHOI DONG NODE C (PORT 8083)
echo ===================================================
start powershell -NoExit -Command ".\mvnw spring-boot:run '-Dspring-boot.run.jvmArguments=-Dserver.port=8083 -Dfile.encoding=UTF-8'"
echo Da mo cua so chay Node C. Vui long doi giay lat...