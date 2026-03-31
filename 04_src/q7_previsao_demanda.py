import pandas as pd
from sklearn.metrics import mean_absolute_error

# carregar dados
df = pd.read_csv('../01_data/processed/vendas_tratadas.csv')
df['sale_date'] = pd.to_datetime(df['sale_date'])

# filtrar produto 54
df = df[df['id_product'] == 54].copy()

# criar série diária preenchendo dias sem venda com 0
date_range = pd.date_range('2023-01-01', '2024-01-31')
df_daily = (
    df.groupby('sale_date')['qtd']
    .sum()
    .reindex(date_range, fill_value=0)
)

# separar treino e teste
train = df_daily[:'2023-12-31']
test = df_daily['2024-01-01':'2024-01-31']

# média móvel de 7 dias (usando apenas dados passados)
forecast = df_daily.shift(1).rolling(7).mean()

# previsões para janeiro
preds = forecast['2024-01-01':'2024-01-31']

# cálculo do erro (MAE)
mae = mean_absolute_error(test, preds)
print(f"MAE: {mae:.2f}")

# soma da previsão na primeira semana de janeiro
print(f"Soma previsão semana 1: {round(preds[:7].sum())}")