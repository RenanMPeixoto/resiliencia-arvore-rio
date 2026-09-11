import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# 1. Configuração de diretórios
PASTA_OUTPUT = 'outputs'
os.makedirs(PASTA_OUTPUT, exist_ok=True)

# 2. Carregamento dos dados
ARQUIVO_ENTRADA = 'chamados_1746_bruto.csv'

if os.path.exists(ARQUIVO_ENTRADA):
    df_bruto = pd.read_csv(ARQUIVO_ENTRADA, parse_dates=['data_inicio', 'data_fim'])
    # Tratamento e Governança
    df = df_bruto.dropna(subset=['nome_bairro', 'subprefeitura']).copy()
    df['resolvido'] = df['data_fim'].notnull()

    def mapear_ap_oficial(subpref):
        sub = str(subpref).lower()
        if 'centro' in sub or 'ilhas' in sub or 'ilha' in sub:
            return 'AP 1 - Centro/Porto'
        elif 'zona sul' in sub:
            return 'AP 2 - Zona Sul'
        elif any(t in sub for t in ['zona norte', 'tijuca', 'complexos']):
            return 'AP 3 - Zona Norte'
        elif 'barra' in sub or 'jacarepaguá' in sub:
            return 'AP 4 - Barra/Jacarepaguá'
        elif 'zona oeste' in sub:
            return 'AP 5 - Zona Oeste'
        return 'Outros'

    df['ap_regiao'] = df['subprefeitura'].apply(mapear_ap_oficial)
    df.to_csv(f'{PASTA_OUTPUT}/chamados_higienizados.csv', index=False)

    # Tabela Executiva
    tabela_executiva = df.groupby('ap_regiao').agg(
        total_chamados=('id_chamado', 'count'),
        chamados_resolvidos=('resolvido', 'sum'),
        sla_mediano_dias=('sla_dias', 'median'),
        sla_medio_dias=('sla_dias', 'mean')
    ).reset_index()
    tabela_executiva['taxa_resolucao_pct'] = (tabela_executiva['chamados_resolvidos'] / tabela_executiva['total_chamados']) * 100
    tabela_executiva = tabela_executiva.sort_values(by='sla_mediano_dias', ascending=False)
    tabela_executiva.to_csv(f'{PASTA_OUTPUT}/tabela_executiva_ap.csv', index=False)

print("Pipeline estruturado com sucesso em pipeline_resiliencia_urbana.py")
