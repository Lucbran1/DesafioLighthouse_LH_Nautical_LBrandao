-- Questão 1.1 - EDA em SQL
-- Dataset: vendas_2023_2024.csv
-- Quantidade de colunas: 6

SELECT
    COUNT(*) AS total_linhas,
    MIN(sale_date) AS data_min,
    MAX(sale_date) AS data_max,
    MIN(total) AS valor_min,
    MAX(total) AS valor_max,
    AVG(total) AS valor_medio
FROM vendas_2023_2024;