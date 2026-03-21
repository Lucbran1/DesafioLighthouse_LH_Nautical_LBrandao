-- ETAPA 1: Integração de dados - Prepara base com vendas, custos e câmbio (Premissa custo LIFO Estoque)
WITH base AS (
    SELECT
        v.id,
        v.id_product,
        v.qtd,
        v.total AS receita,
        v.sale_date,
        c.usd_price,
        cb.valor AS cambio,

        -- Cálcula o custo total em BRL por transação 
        (c.usd_price * cb.valor * v.qtd) AS custo_total_brl

    FROM vendas_tratadas v

    -- Pega o custo importação mais recente até a data da venda 
    LEFT JOIN custos_importacao_tratado c
        ON v.id_product = c.product_id
        AND c.start_date = (
            SELECT MAX(c2.start_date)
            FROM custos_importacao_tratado c2
            WHERE c2.product_id = v.id_product
              AND c2.start_date <= v.sale_date
        )
    -- Pega o câmbio da data da venda ou do último dia útil anterior
    LEFT JOIN cambio_tratado cb
        ON cb.data = (
            SELECT MAX(cb2.data)
            FROM cambio_tratado cb2
            WHERE cb2.data <= v.sale_date
        )
)
-- ETAPA 2: Agregação - Calcula receita, prejuízo e percentual por produto
SELECT
    id_product,
    -- Receita total do produto (todas as vendas)
    SUM(receita) AS receita_total,

    -- Prejuízo total = soma apenas das transações com prejuízo (custo > receita)
    SUM(
        CASE 
            WHEN receita < custo_total_brl  
            THEN receita - custo_total_brl 
            ELSE 0
        END
    ) AS prejuizo_total,

    -- Percentual de perda = prejuízo total / receita total 
    SUM(
        CASE 
            WHEN receita < custo_total_brl  
            THEN custo_total_brl - receita
            ELSE 0
        END
    ) / SUM(receita) AS percentual_perda

-- Agrega por produto e ordena do maior prejuízo para o menor
FROM base
GROUP BY id_product
ORDER BY prejuizo_total DESC;




-- Cenário 2 Premissa utilizando Custo Médio de Estoque  
WITH base AS (
    SELECT
        v.id,
        v.id_product,
        v.qtd,
        v.total AS receita,
        v.sale_date,

        -- custo médio por produto
        c_avg.avg_usd_price AS usd_price,

        cb.valor AS cambio,

        -- custo total em BRL
        (c_avg.avg_usd_price * cb.valor * v.qtd) AS custo_total_brl

    FROM vendas_tratadas v

    --  CUSTO MÉDIO POR PRODUTO
    LEFT JOIN (
        SELECT 
            product_id,
            AVG(usd_price) AS avg_usd_price
        FROM custos_importacao_tratado
        GROUP BY product_id
    ) c_avg
        ON v.id_product = c_avg.product_id

    -- câmbio mais recente <= data venda
    LEFT JOIN cambio_tratado cb
        ON cb.data = (
            SELECT MAX(cb2.data)
            FROM cambio_tratado cb2
            WHERE cb2.data <= v.sale_date
        )
)

SELECT
    id_product,

    SUM(receita) AS receita_total,

    SUM(
        CASE 
            WHEN receita < custo_total_brl  
            THEN receita - custo_total_brl 
            ELSE 0
        END
    ) AS prejuizo_total,

    SUM(
        CASE 
            WHEN receita < custo_total_brl  
            THEN custo_total_brl - receita
            ELSE 0
        END
    ) / SUM(receita) AS percentual_perda

FROM base
GROUP BY id_product
ORDER BY prejuizo_total DESC;