-- Confronto: Passivo preventivo de podas vs. Quedas emergenciais no Vendaval de Julho/2026
WITH chamados_emergenciais AS (
    SELECT 
        b.subprefeitura,
        COUNT(c.id_chamado) AS total_quedas_emergenciais
    FROM 
        `datario.adm_central_atendimento_1746.chamado` AS c
    LEFT JOIN 
        `datario.dados_mestres.bairro` AS b 
        ON c.id_bairro = b.id_bairro
    WHERE 
        DATE(c.data_inicio) BETWEEN '2026-07-29' AND '2026-08-02'
        AND (
            LOWER(c.subtipo) LIKE '%queda de árvore%' 
            OR LOWER(c.subtipo) LIKE '%árvore caída%'
            OR LOWER(c.subtipo) LIKE '%remoção de árvore%'
        )
    GROUP BY 
        b.subprefeitura
),
passivo_preventivo AS (
    SELECT 
        b.subprefeitura,
        COUNT(c.id_chamado) AS total_podas_pendentes_pre_evento
    FROM 
        `datario.adm_central_atendimento_1746.chamado` AS c
    LEFT JOIN 
        `datario.dados_mestres.bairro` AS b 
        ON c.id_bairro = b.id_bairro
    WHERE 
        DATE(c.data_inicio) BETWEEN '2026-02-01' AND '2026-07-28'
        AND LOWER(c.subtipo) LIKE '%poda de árvore%'
        AND (c.data_fim IS NULL OR DATE(c.data_fim) > '2026-07-28')
    GROUP BY 
        b.subprefeitura
)
SELECT 
    COALESCE(p.subprefeitura, e.subprefeitura) AS subprefeitura,
    COALESCE(p.total_podas_pendentes_pre_evento, 0) AS podas_pendentes,
    COALESCE(e.total_quedas_emergenciais, 0) AS quedas_registradas
FROM 
    passivo_preventivo AS p
FULL OUTER JOIN 
    chamados_emergenciais AS e 
    ON p.subprefeitura = e.subprefeitura
ORDER BY 
    quedas_registradas DESC;