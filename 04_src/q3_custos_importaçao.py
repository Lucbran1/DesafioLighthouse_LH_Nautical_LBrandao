import pandas as pd

# Carregar JSON
df = pd.read_json("../01_data/raw/custos_importacao.json")

# Explodir lista
df = df.explode("historic_data")

# Expandir JSON aninhado
df_hist = pd.json_normalize(df["historic_data"])

# Juntar tudo
df_final = pd.concat(
    [
        df[["product_id", "product_name", "category"]].reset_index(drop=True),
        df_hist.reset_index(drop=True)
    ],
    axis=1
)

# Salvar CSV
df_final.to_csv("../01_data/processed/custos_importacao_tratado.csv", index=False)

# Validação
print(len(df_final))