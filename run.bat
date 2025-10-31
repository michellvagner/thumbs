chcp 65001
@echo off

set OUTPUT=%USERPROFILE%\repos\local\dados
set OUTPUT=%OUTPUT:\=/%

set FILE=%USERPROFILE%\repos\local\queries\comandos.sql
set FILE=%FILE:\=/%

echo.
echo ============================================
echo.
echo [INFO] Iniciando extracao Black friday
echo.

if not exist "%OUTPUT%" mkdir "%OUTPUT%"
if exist "%OUTPUT%\alertas.csv" del "%OUTPUT%\alertas.csv"

snowsql -c snow_conexoes -f "%FILE%" --variable variavel="%OUTPUT%" -o variable_substitution=true

echo [INFO] Arquivos extraidos em "%OUTPUT%"
echo [INFO] Fim Execução
echo.

PAUSE