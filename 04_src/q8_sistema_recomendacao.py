import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity

# leitura dos dados
vendas = pd.read_csv('../01_data/processed/vendas_tratadas.csv')
produtos = pd.read_csv('../01_data/processed/produtos_tratados.csv')

# base cliente-produto (presença de compra)
df = vendas[['id_client', 'id_product']].drop_duplicates()
df['compra'] = 1

# matriz usuário x produto
matriz = df.pivot(index='id_client', columns='id_product', values='compra').fillna(0)

# matriz produto x cliente
matriz_produto = matriz.T

# similaridade de cosseno entre produtos
similaridade = cosine_similarity(matriz_produto)

sim_df = pd.DataFrame(
    similaridade,
    index=matriz_produto.index,
    columns=matriz_produto.index
)

# identifica o id do GPS
gps_id = produtos.loc[
    produtos['name'].str.contains('Garmin Vortex', case=False, na=False),
    'code'
].values[0]

# ranking de produtos mais similares (exclui o próprio GPS antes do top 5)
ranking = (
    sim_df[gps_id]
    .drop(gps_id)
    .sort_values(ascending=False)
    .head(5)
)

# adiciona nome do produto ao ranking
ranking = ranking.reset_index()
ranking.columns = ['id_product', 'similaridade']

ranking = ranking.merge(
    produtos[['code', 'name']],
    left_on='id_product',
    right_on='code',
    how='left'
)

ranking[['id_product', 'name', 'similaridade']]