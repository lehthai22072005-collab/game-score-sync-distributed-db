@echo off
echo ===================================================
echo KHOI DONG NODE B (PORT 8082)
echo ===================================================
start powershell -NoExit -Command ".\mvnw spring-boot:run '-Dspring-boot.run.jvmArguments=-Dserver.port=8082 -Dfile.encoding=UTF-8'"
echo Da mo cua so chay Node B. Vui long doi giay lat...