-- Objetivo: calcular a média de vendas por dia da semana considerando dias sem venda

-- Cria calendário completo com todas as datas do período (inclusivo)
WITH RECURSIVE calendario AS (
    SELECT DATE('2023-01-01') AS data
    
    UNION ALL
    
    SELECT DATE_ADD(data, INTERVAL 1 DAY)
    FROM calendario
    WHERE data < DATE('2024-12-31') -- garante inclusão do último dia
),

-- Agrega as vendas por dia (somando todas as transações do dia)
vendas_por_dia AS (
    SELECT 
        DATE(STR_TO_DATE(sale_date, '%Y-%m-%d')) AS data,
        SUM(total) AS total_dia
    FROM vendas_tratadas
    GROUP BY DATE(STR_TO_DATE(sale_date, '%Y-%m-%d'))
),

-- Junta calendário com vendas e trata dias sem venda como zero
base_final AS (
    SELECT 
        c.data,
        COALESCE(v.total_dia, 0) AS total_dia,
        
        -- Converte número do dia da semana para nome em português
        CASE DAYOFWEEK(c.data)
            WHEN 1 THEN 'domingo'
            WHEN 2 THEN 'segunda-feira'
            WHEN 3 THEN 'terça-feira'
            WHEN 4 THEN 'quarta-feira'
            WHEN 5 THEN 'quinta-feira'
            WHEN 6 THEN 'sexta-feira'
            WHEN 7 THEN 'sábado'
        END AS dia_semana
        
    FROM calendario c
    LEFT JOIN vendas_por_dia v
        ON c.data = v.data
)

-- Calcula a média de vendas por dia da semana e ordena do pior para o melhor
SELECT 
    dia_semana,
    ROUND(AVG(total_dia), 2) AS media_vendas
FROM base_final
GROUP BY dia_semana
ORDER BY media_vendas ASC;