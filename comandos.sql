!set header=true
!set friendly=false
!set output_format=csv

!print ============================================
!print INICIANDO EXECUÇÃO DAS QUERIES
!print ============================================

!print [INFO] Executando: Criando dependencias...
!set quiet=true
create or replace temporary table CUR_ETHOS_FDW.FDW.parametro_dt as
select date('2025-09-08') as data;
!set quiet=false
!print [INFO] Executando: Exportando alertas...
!set quiet=true
!set output_file="&variavel/alertas.csv"
SELECT
     *
FROM CUR_ETHOS_FDW.FDW.FALCON_AUTHORIZATION_VAGNER_MICHELL where data_transacao >= (select data from CUR_ETHOS_FDW.FDW.parametro_dt );
!set quiet=false