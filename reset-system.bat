@echo off
echo ===================================================
echo KICH BAN RESET HE THONG (XOA SACH DU LIEU CU)
echo ===================================================

echo [1/3] Dang don dEP cac file Snapshot tren RAM...
del /q snapshot_*.txt 2>nul
echo - Da xoa sach cac file diem so cu!

echo [2/3] Dang xoa toan bo tri nho cua Kafka va Zookeeper...
:: Lenh 'down -v' se tat Kafka va xoa sach cac volume du lieu ben trong no
docker-compose down -v

echo [3/3] Dang khoi dong lai ha tang trang tinh...
docker-compose up -d zookeeper
echo - Vui long doi 20 giay cho tong dai Zookeeper on dinh...
timeout /t 20 /nobreak
docker-compose up -d kafka

echo.
echo ===================================================
echo HOAN TAT! He thong da tro ve trang thai "Trang tinh".
echo Ban co the chay lai file "run-3-nodes.bat" de bat dau Test.
echo ===================================================
pause