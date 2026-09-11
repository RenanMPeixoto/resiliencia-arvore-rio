Resiliência Urbana e Manejo Arbóreo no Rio de Janeiro
Por Que Velocidade Operacional (SLA) Não Mitiga Riscos Climáticos Extremos
1. Contexto e Problema de Negócio

A intensificação de tempestades severas e frentes frias no Rio de Janeiro impõe desafios severos à zeladoria urbana. A queda recorrente de árvores em dias de chuva e ventania não causa apenas congestionamentos; destrói a rede elétrica, paralisa corredores de transporte e coloca vidas em risco.

Historicamente, a gestão pública avalia a eficiência de suas secretarias por meio de métricas de esforço: o tempo de atendimento (SLA) dos chamados do canal 1746. Focar unicamente na velocidade de fechamento de chamados, porém, cria uma métrica de vaidade: atender rápido não significa mitigar o dano estrutural da cidade.

Objetivo: investigar os chamados de manejo arbóreo (poda e conservação) para entender as disparidades regionais de atendimento no período pré-chuvas, e testar se um SLA operacional mais baixo blindou os bairros contra o vendaval histórico de 29/07/2026.
Impacto esperado: fornecer à Secretaria de Conservação e à Comlurb uma diretriz prescritiva para transitar de uma operação reativa para um modelo de manutenção preventiva baseado em risco geográfico.
2. Governança e Linhagem dos Dados (GIGO)

Dados extraídos e tratados a partir dos repositórios oficiais da Prefeitura do Rio, com foco nas dimensões de Validade, Consistência, Completude e Atualização.

Armazenamento e extração: Google Cloud Platform (BigQuery), consultando datario.adm_central_atendimento_1746.chamado integrado à tabela dimensional datario.dados_mestres.bairro.

Tratamento e engenharia (Fix, Drop, Impute, Flag):

Drop: descarte de registros sem ancoragem territorial (31 linhas com bairro/subprefeitura nulos, < 0,8% da base).

Flag: criação do indicador booleano resolvido (data_fim.notnull()) para tratar separadamente o passivo pendente e evitar viés de sobrevivência.

Fix (consistência territorial): correção da classificação das subprefeituras da Grande Tijuca e dos Grandes Complexos, incorporando 377 chamados à AP 3 (Zona Norte) que haviam sido omitidos pela rotina de texto simples.

Data Tracking Sheet do Projeto
Pergunta de Negócio	Dado / Atributo	Base ou Calculada?	Cálculo / Regra de Negócio	Fonte

Qual chamado foi aberto e qual o serviço?	id_chamado, subtipo	Base	

Filtro: "Poda de árvore em logradouro"	Data.Rio (chamado)

Em qual macrozona ocorreu a demanda?	ap_regiao, subprefeitura	
Calculada	Mapeamento por correspondência textual das subprefeituras oficiais	Data.Rio (bairro)
Quando foi solicitado e quando encerrado?	data_inicio, data_fim	
Base	Parsing temporal em datetime64[ns]	Data.Rio (chamado)
Quanto tempo a Prefeitura levou para atender?	sla_dias	Calculada	DATE_DIFF(DATE(data_fim), DATE(data_inicio), DAY)	Calculada via DQL/Pandas

O serviço foi efetivamente executado?	resolvido	
Calculada	Booleano: True se data_fim preenchida	Calculada
Qual o backlog pré-evento climático?	podas_pendentes	Calculada	
Volume sem conclusão aberto entre Fev/2026 e 28/07/2026	BigQuery / 1746
Qual o dano real sofrido no vendaval?	quedas_registradas	Calculada	
Chamados de emergência de queda (29/07 a 02/08/2026)	BigQuery / 1746

3. Metodologia e Hipótese
Métrica central robusta: substituição da média aritmética pela mediana. Outliers extremos (chamados que levaram até 743 dias para fechar) inflavam a média municipal para 101 dias, mascarando que 50% dos chamados da cidade são atendidos em até 21 dias.
Hipótese de trabalho:

Um menor passivo de podas pendentes nos 6 meses anteriores ao evento está associado a uma diminuição superior a 40% no volume de chamados de queda de árvore durante a semana do vendaval de 29/07/2026.

4. Resultados e Storytelling Explanatório
Visualização 1 — O Paradoxo da Zona Sul (Rotina Pré-Verão)

Mostrar Imagem

Diagnóstico: a AP 2 (Zona Sul) apresentou o pior SLA mediano da cidade — 237 dias (quase 8 meses) para atender uma poda preventiva. Em contraste, a AP 5 (Zona Oeste) atingiu 6 dias, e a AP 3 (Zona Norte) registrou 22 dias, absorvendo o maior volume absoluto (1.918 chamados).
Hipótese de causa raiz (não testada estatisticamente): a morosidade na Zona Sul provavelmente reflete restrições de processo — exigência de laudos prévios para árvores centenárias tombadas (Fundação Parques e Jardins), desligamento programado da rede aérea de alta tensão (Light) e restrições de tráfego da CET-Rio em vias adensadas. Essa leitura é qualitativa, baseada em conhecimento de domínio sobre o rito administrativo da região, e não em uma variável mensurada no dataset — fica como hipótese para validação em uma próxima etapa (ex.: cruzar com chamados que registram motivo de pendência).
Visualização 2 — O Teste de Estresse Climático (Vendaval de Julho/2026)

Mostrar Imagem

Teste da hipótese: se a hipótese estivesse correta, a região com menor backlog e SLA mais rápido (AP 5, 6 dias) deveria concentrar a menor proporção de quedas no vendaval. Os dados mostram o oposto: a AP 5 registrou mais de 340 árvores tombadas — o maior volume de danos entre as regiões analisadas —, apesar do backlog pré-evento reduzido. A hipótese é rejeitada: a redução do passivo operacional não se traduziu na queda superior a 40% prevista; na região de melhor performance de SLA, o dano observado foi, na verdade, o mais severo.

Insight estratégico: a velocidade de fechamento de chamados pontuais funcionou como métrica de vaidade. A Zona Oeste sofreu destruição em massa por fatores exógenos ao processo administrativo — hipoteticamente, rajadas de vento canalizadas em áreas descampadas, topografia desprotegida e espécies arbóreas mais vulneráveis ao cisalhamento (fatores não mensurados diretamente neste dataset, citados aqui como leitura de contexto, não como achado estatístico). A resposta rápida da rotina não se traduziu em resiliência climática.

5. Limitações e Próximos Passos
Subnotificação: nem toda árvore caída ou em risco gera um chamado 1746 — o dataset capta apenas o que foi formalmente reportado, o que pode subestimar o problema em regiões com menor engajamento cidadão no canal.
Completude variável por região: a qualidade do preenchimento de campos (bairro, subtipo, datas) pode variar entre subprefeituras, afetando comparações diretas de volume.

Causas exógenas não mensuradas: variáveis como velocidade do vento, cobertura de copa e espécie da árvore não estão no dataset do 1746 e precisariam de fontes externas (ex.: dados meteorológicos, INEA) para sair do campo da hipótese qualitativa.
Próximo passo natural: enriquecer a análise com dados de vento/pluviometria por região para testar estatisticamente os fatores exógenos citados na Seção 4, e não apenas assumi-los por conhecimento de domínio.
7. Recomendações Prescritivas (Framework CAMS)

Cultura: alterar a remuneração e metas dos distritos operacionais da Comlurb. O foco deve deixar de ser o menor SLA em dias (que incentiva o fechamento de podas fáceis) e passar a ser o Índice de Cobertura Arbórea Crítica.

Automação: implementar rotinas em nuvem (BigQuery + APIs meteorológicas) para alertar automaticamente as subprefeituras sobre corredores de ventania iminente, despachando caminhões com antecedência para as vias arteriais de maior risco.

Métricas: instituir meta mandatória de redução do passivo — nenhuma árvore em corredores estruturais deve permanecer mais de 30 dias em backlog durante outono e inverno.

Compartilhamento: criar comitê integrado de despacho (Comlurb, Defesa Civil, CET-Rio e Light) para destravar autorizações e desligamentos conjuntos na Zona Sul, reduzindo o tempo de atendimento de 237 para menos de 60 dias.

8. Como Reproduzir
bash
git clone <repo>
cd <repo>
pip install -r requirements.txt

Configure as credenciais do BigQuery (variável de ambiente GOOGLE_APPLICATION_CREDENTIALS apontando para o JSON da service account).
Execute as queries em sql/ para extrair os dados brutos.

Rode notebooks/analise_exploratoria_1746.ipynb para reproduzir a limpeza e o profiling.

Rode scripts/pipeline_resiliencia_urbana.py para gerar as figuras e a tabela executiva em outputs/.

10. Estrutura do Repositório
    
text
├── README.md                           # Storytelling executivo e documentação
├── requirements.txt                    # Dependências do projeto
├── sql/
│   ├── 01_extracao_preventiva_2023.sql # DQL no BigQuery (recorte de rotina)
│   └── 02_extracao_estresse_2026.sql   # DQL no BigQuery (confronto vendaval)
├── notebooks/
│   └── analise_exploratoria_1746.ipynb # Profiling, limpeza e exploração
├── scripts/
│   └── pipeline_resiliencia_urbana.py  # Pipeline ponta a ponta em Python
└── outputs/
    ├── fig1_gargalo_sla_zona_sul.png   # Visualização explanatória 1
    └── fig2_dispersao_passivo_vs_quedas.
