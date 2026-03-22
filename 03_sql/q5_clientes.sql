--  Análise de Clientes Fiéis

WITH base AS (
    -- Integração das tabelas: vendas + produtos + clientes
    SELECT
        v.id_client,
        c.full_name,
        v.id,
        v.qtd,
        v.total,
        p.actual_category
    FROM lh_nautical_db.vendas_tratadas v
    LEFT JOIN lh_nautical_db.produtos_tratados p
        ON v.id_product = p.code
    LEFT JOIN lh_nautical_db.clientes_crm c
        ON v.id_client = c.code
),

clientes_metricas AS (
    -- Cálculo das métricas por cliente: frequência, faturamento, ticket médio e diversidade
    SELECT
        id_client,
        full_name,
        COUNT(id) AS frequencia,
        SUM(total) AS faturamento_total,
        SUM(total) / COUNT(id) AS ticket_medio,
        COUNT(DISTINCT actual_category) AS diversidade
    FROM base
    GROUP BY id_client, full_name
),

top_clientes AS (
    -- Seleção dos clientes fiéis: diversidade >= 3 e maior ticket médio
    SELECT *
    FROM clientes_metricas
    WHERE diversidade >= 3
    ORDER BY ticket_medio DESC, id_client ASC
    LIMIT 10
),

categoria_top AS (
    -- Soma da quantidade de itens por categoria considerando apenas os Top 10 clientes
    SELECT
        b.actual_category,
        SUM(b.qtd) AS total_itens
    FROM base b
    INNER JOIN top_clientes t
        ON b.id_client = t.id_client
    GROUP BY b.actual_category
)

-- Resultado final: categoria com maior volume de itens vendidos
SELECT
    actual_category,
    total_itens
FROM categoria_top
ORDER BY total_itens DESC
LIMIT 1;
