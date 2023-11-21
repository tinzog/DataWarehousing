@echo off
REM Define the SA password and other variables
SET SA_PASSWORD=Password+123
SET SSQL_PORT=2019
SET CONTAINER_NAME=SQL19

REM Main entry point
call :init-all
goto end

REM Function to pull Docker image
:pull-image
echo Pulling Docker image...
docker pull mcr.microsoft.com/mssql/server:2019-latest
goto:eof

REM Function to run Docker container
:run-container
echo Running Docker container...
docker rm -f %CONTAINER_NAME% 2> NUL
docker run --name %CONTAINER_NAME% -p %SSQL_PORT%:1433 -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=%SA_PASSWORD%" -d mcr.microsoft.com/mssql/server:2019-latest
goto:eof

REM Function to setup backup
:setup-backup
echo Setting up backup...
docker exec -it SQL19 mkdir /var/opt/mssql/backup 2> NUL
docker cp databases/Quelle_csv_load.bak SQL19:/var/opt/mssql/backup
docker cp databases/Quelle_OLTP_System.bak SQL19:/var/opt/mssql/backup
goto:eof

REM Function to restore database
:restore-db
echo Restoring database...
docker exec -it SQL19 /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "%SA_PASSWORD%" -Q "RESTORE DATABASE Quelle_csv FROM DISK = '/var/opt/mssql/backup/Quelle_csv_load.bak' WITH MOVE 'Quelle_csv' TO '/var/opt/mssql/data/Quelle_csv', MOVE 'Quelle_csv_log' TO '/var/opt/mssql/data/Quelle_csv_log'"
docker exec -it SQL19 /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "%SA_PASSWORD%" -Q "RESTORE DATABASE Quelle_OLTP FROM DISK = '/var/opt/mssql/backup/Quelle_OLTP_System.bak' WITH MOVE 'Quelle_OLTP_System' TO '/
