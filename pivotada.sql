create or replace temporary table cur_ethos_fdw.fdw.parametro_dt as
with parametro as 
(
select
    '2024-11-24'::DATE as data_inicio_black_friday_atual,
    '2024-11-29'::DATE as data_fim_black_friday_atual
)
select
    datediff(day, data_inicio_black_friday_atual, data_fim_black_friday_atual) +1 as total_dias
    from parametro
;;

set total_dias=(select total_dias from cur_ethos_fdw.fdw.parametro_dt)

;;

set expressao_soma = (
with sequencia as 
(
select row_number() over (order by 1) as seq
    from table(generator(rowcount => $total_dias))
)
select
    listagg('$' || (1 + seq), '+') within group (order by seq) as resultado_str
    from sequencia )
	
;;

set query_pivotada = 
'select *,' || $expressao_soma || ' as total
FROM cur_ethos_fdw.fdw.vendas_original
PIVOT (
    SUM(valor) FOR data IN (any order by data) default on null (0)
)'

;;

EXECUTE IMMEDIATE $query_pivotada;