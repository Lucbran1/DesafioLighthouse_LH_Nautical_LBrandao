import pandas as pd

df_prod = pd.read_csv("../01_data/raw/produtos_raw.csv")

# Padronização de categorias
def padronizar_categoria(cat):
    cat = str(cat).lower().replace(" ", "").strip()

    if 'eletr' in cat:
        return 'eletrônicos'
    elif 'prop' in cat:   
        return 'propulsão'
    elif 'ancor' in cat or 'encor' in cat:
        return 'ancoragem'
    else:
        return cat

df_prod['actual_category'] = df_prod['actual_category'].apply(padronizar_categoria)

# Conversão para numérico
df_prod['price'] = (
    df_prod['price']
    .str.replace('R$', '', regex=False)
    .str.strip()
    .astype(float)
)

# Remoção de duplicatas
num_antes = df_prod.shape[0]
df_prod = df_prod.drop_duplicates()
num_depois = df_prod.shape[0]
duplicados_removidos = num_antes - num_depois
print(duplicados_removidos)

# Salvando dataset tratado
df_prod.to_csv("../01_data/processed/produtos_tratados.csv", index=False)