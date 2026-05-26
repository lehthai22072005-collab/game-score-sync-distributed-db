@echo off
echo [1/3] Dang bat Zookeeper truoc...
docker-compose up -d zookeeper

echo [2/3] Vui long doi 20 giay de Zookeeper khoi dong hoan toan...
timeout /t 20 /nobreak

echo [3/3] Dang bat tiep Kafka...
docker-compose up -d kafka

echo HOAN TAT! He thong da san sang.
pause