@echo off
chcp 65001

set "ARQUIVO=%USERPROFILE%\repos\local\dados\simulacao.txt"
set "TABELA=DATABASENAME.SCHEMA.simulacao_%USERNAME%"
set "TABELA=%TABELA: =_%"

echo.
echo INICIANDO PROCESSO COMPLETO
echo.

echo 1. Criando tabela completa...
snowsql -c snow_conexoes -q "CREATE OR REPLACE TABLE %TABELA% (id_transacao STRING, organizacao STRING, num_crt STRING, data_transacao STRING, vlr_fat STRING, tpo STRING, num_mcc STRING, estabelecimento STRING, nome_estabelecimento STRING, score_master STRING, score_visa STRING, score_falcon STRING, moeda STRING, iso_pais STRING)"
if %ERRORLEVEL% EQU 0 (echo Tabela criada) else (echo  Erro na tabela)

echo.
echo 2. Fazendo upload do arquivo...
snowsql -c snow_conexoes -q "PUT 'file://%ARQUIVO:\=/%' @~ AUTO_COMPRESS=FALSE OVERWRITE=TRUE"
if %ERRORLEVEL% EQU 0 (echo Upload feito) else (echo Erro no upload)

echo.
echo 3. Carregando dados para a tabela...
snowsql -c snow_conexoes -q "COPY INTO %TABELA% FROM @~/simulacao.txt FILE_FORMAT=(TYPE=CSV FIELD_DELIMITER='\t' SKIP_HEADER=1)"
if %ERRORLEVEL% EQU 0 (echo Dados carregados) else (echo Erro ao carregar)

echo.
echo 4. Removendo arquivo da stage...
snowsql -c snow_conexoes -q "REMOVE @~/simulacao.txt"
if %ERRORLEVEL% EQU 0 (echo Stage limpa) else (echo Erro ao limpar stage)

echo.
echo 5. Tipando a tabela...
snowsql -c snow_conexoes -q "CREATE OR REPLACE TABLE DATABASENAME.SCHEMA.simulacao_VAGNER_MICHELL AS SELECT ID_TRANSACAO, ORGANIZACAO, NUM_CRT, TO_TIMESTAMP(DATA_TRANSACAO, 'YYYY-MM-DD"T"HH24:MI:SS.FFTZH:TZM') DATA_TRANSACAO, to_decimal(vlr_fat, 10, 2) VLR_FAT, TPO, NUM_MCC, ESTABELECIMENTO,  NOME_ESTABELECIMENTO, TO_NUMBER(SCORE_MASTER) SCORE_MASTER, TO_NUMBER(SCORE_VISA) SCORE_VISA, TO_NUMBER(SCORE_FALCON) SCORE_FALCON, MOEDA, ISO_PAIS FROM DATABASENAME.SCHEMA.simulacao_VAGNER_MICHELL;"

echo.
echo 6. Verificando dados na tabela...
snowsql -c snow_conexoes -q "SELECT 'SUCESSO - ' || COUNT(*) || ' registros' FROM %TABELA%"

echo.
echo 7. Mostrando primeiros registros...
snowsql -c snow_conexoes -q "SELECT * FROM %TABELA% LIMIT 3"


echo.
echo PROCESSO CONCLUÍDO!
pause