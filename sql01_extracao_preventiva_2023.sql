-- Extração de chamados de manejo arbóreo e cruzamento territorial (Pré-verão 2023)
SELECT 
    c.id_chamado,
    c.subtipo,
    c.status,
    c.data_inicio,
    c.data_fim,
    DATE_DIFF(DATE(c.data_fim), DATE(c.data_inicio), DAY) AS sla_dias,
    b.nome AS nome_bairro,
    b.subprefeitura
FROM 
    `datario.adm_central_atendimento_1746.chamado` AS c
LEFT JOIN 
    `datario.dados_mestres.bairro` AS b 
    ON c.id_bairro = b.id_bairro
WHERE 
    DATE(c.data_inicio) BETWEEN '2023-10-01' AND '2023-11-30'
    AND LOWER(c.subtipo) LIKE '%poda de árvore%';