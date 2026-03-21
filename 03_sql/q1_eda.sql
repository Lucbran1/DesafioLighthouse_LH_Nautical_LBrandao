-- Questão 1.1 - EDA em SQL
-- Dataset: vendas_2023_2024.csv
-- =========================================

SELECT COUNT(*) AS total_colunas       -- quantidade total de colunas
FROM information_schema.columns
WHERE table_schema = 'lh_nautical_db'
  AND table_name = 'vendas_2023_2024';

SELECT
    COUNT(*) AS total_linhas,          -- quantidade total de linhas
    MIN(sale_date) AS data_min,        -- data mínima
    MAX(sale_date) AS data_max,        -- data máxima
    MIN(total) AS valor_min,           -- valor mínimo
    MAX(total) AS valor_max,           -- valor máximo
    AVG(total) AS valor_medio          -- valor médio
FROM lh_nautical_db.vendas_2023_2024;

