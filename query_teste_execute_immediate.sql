-- Tabela de vendas original
CREATE OR REPLACE TEMPORARY TABLE cur_ethos_fdw.fdw.vendas_original AS
SELECT * FROM VALUES
    ('Loja_A', '2024-11-24'::DATE, 100),
    ('Loja_A', '2024-11-25'::DATE, 150),
    ('Loja_A', '2024-11-26'::DATE, 200),
    ('Loja_B', '2024-11-24'::DATE, 80),
    ('Loja_B', '2024-11-25'::DATE, 120),
    ('Loja_B', '2024-11-28'::DATE, 90),
    ('Loja_B', '2024-11-29'::DATE, 90),
    ('Loja_B', '2024-11-29'::DATE, 90),
    ('Loja_B', '2024-11-28'::DATE, 90)
AS t(loja, data, valor);

SELECT * FROM cur_ethos_fdw.fdw.vendas_original;

;;

-----------------------------------------------------------------


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

create or replace temporary table cur_ethos_fdw.fdw.dcalendario as
SELECT DATEADD(day, seq4(), '2024-11-24'::DATE) AS data
    FROM TABLE(GENERATOR(ROWCOUNT => ( $total_dias )
    ))

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

with cte_vendas_completa as
(
select 
    calendario.data,
    vendas.* exclude(data, valor),
    coalesce(valor, 0) as valor
    from cur_ethos_fdw.fdw.dcalendario calendario
    left join cur_ethos_fdw.fdw.vendas_original vendas
    on calendario.data = vendas.data
)
select * 
from cte_vendas_completa
PIVOT ( SUM( valor ) FOR data IN (any order by data) default on null (0) )
;;

set query0 =
$$
CREATE OR REPLACE temporary TABLE cur_ethos_fdw.fdw.resultado_pivot_vagner AS
$$

;;
set query1 = $$
with cte_vendas_completa as
    (
    select 
    calendario.data,
    vendas.* exclude(data, valor),
    coalesce(valor, 0) as valor
    from cur_ethos_fdw.fdw.dcalendario calendario
$$

;;

set query2 = $$
left join cur_ethos_fdw.fdw.vendas_original vendas
    on calendario.data = vendas.data
    )
    select *,
$$

;;

set query3 = $$
as total
    from cte_vendas_completa
    PIVOT ( SUM( valor ) FOR data IN (any order by data) default on null (0) )
$$

;;

EXECUTE IMMEDIATE
$$
DECLARE query_pivotada varchar;
BEGIN    
    query_pivotada:= CONCAT($query0, $query1, $query2, $expressao_soma, $query3);
    EXECUTE IMMEDIATE :query_pivotada;
END;
$$;


SHOW COLUMNS IN TABLE cur_ethos_fdw.fdw.resultado_pivot_vagner;
;;

SELECT 
    * exclude(TOTAL) 
FROM cur_ethos_fdw.fdw.resultado_pivot_vagner
UNPIVOT (valor FOR data_str IN (
    "'2024-11-24'",
    "'2024-11-25'", 
    "'2024-11-26'",
    "'2024-11-27'",
    "'2024-11-28'",
    "'2024-11-29'"
));

