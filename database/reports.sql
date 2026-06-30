USE petvida;

-- 1) Ranking de tutores que mais gastam
SET @pos := 0;
SELECT
    @pos := @pos + 1 AS posicao,
    ranking.tutor AS nome,
    ranking.total_gasto AS total,
    ranking.qtd_consultas
FROM (
    SELECT
        t.nome AS tutor,
        SUM(c.valor_total) AS total_gasto,
        COUNT(*) AS qtd_consultas
    FROM consultas c
    INNER JOIN animais a ON c.animal_id = a.id
    INNER JOIN tutores t ON a.tutor_id = t.id
    WHERE c.status = 'concluida'
    GROUP BY t.id, t.nome
    ORDER BY total_gasto DESC
) AS ranking;

-- 2) Faturamento mensal
SELECT
    YEAR(c.data_hora) AS ano,
    MONTH(c.data_hora) AS mes,
    COUNT(*) AS total_consultas,
    SUM(c.valor_total) AS bruto,
    SUM(CASE WHEN p.status = 'pago' THEN p.valor_pago ELSE 0 END) AS recebido,
    SUM(CASE WHEN p.status = 'pendente' OR p.status IS NULL THEN c.valor_total ELSE 0 END) AS pendente
FROM consultas c
LEFT JOIN (
    SELECT
        consulta_id,
        MAX(status) AS status,
        SUM(valor_pago) AS valor_pago
    FROM pagamentos
    GROUP BY consulta_id
) p ON c.id = p.consulta_id
WHERE c.status = 'concluida'
GROUP BY ano, mes
ORDER BY ano DESC, mes DESC;

-- 3) Animais sem consulta há 6+ meses (inclui nunca consultados)
SELECT
    a.id AS animal_id,
    a.nome AS animal,
    t.nome AS tutor,
    e.nome AS especie,
    MAX(c.data_hora) AS ultima_consulta,
    CASE
        WHEN MAX(c.data_hora) IS NULL THEN 'Nunca'
        ELSE DATE_FORMAT(MAX(c.data_hora), '%Y-%m-%d')
    END AS ultima_visita
FROM animais a
INNER JOIN tutores t ON a.tutor_id = t.id
INNER JOIN especies e ON a.especie_id = e.id
LEFT JOIN consultas c ON a.id = c.animal_id
GROUP BY a.id, a.nome, t.nome, e.nome
HAVING MAX(c.data_hora) IS NULL
    OR DATEDIFF(CURDATE(), MAX(c.data_hora)) >= 180
ORDER BY ultima_consulta ASC;

-- 4) Dashboard financeiro
SELECT
    COUNT(*) AS total_consultas,
    SUM(c.valor_total) AS bruto,
    SUM(CASE WHEN p.status = 'pago' THEN p.valor_pago ELSE 0 END) AS recebido,
    SUM(CASE WHEN p.status = 'pendente' OR p.status IS NULL THEN c.valor_total ELSE 0 END) AS pendente,
    ROUND(
        CASE WHEN SUM(c.valor_total) = 0 THEN 0
             ELSE SUM(CASE WHEN p.status = 'pendente' OR p.status IS NULL THEN c.valor_total ELSE 0 END) * 100 / SUM(c.valor_total)
        END,
        2
    ) AS percentual_inadimplencia
FROM consultas c
LEFT JOIN (
    SELECT
        consulta_id,
        MAX(status) AS status,
        SUM(valor_pago) AS valor_pago
    FROM pagamentos
    GROUP BY consulta_id
) p ON c.id = p.consulta_id
WHERE c.status = 'concluida';

-- 5) Veterinário do mês
SELECT
    v.nome AS veterinario,
    COUNT(*) AS total_consultas,
    SUM(c.valor_total) AS faturamento
FROM consultas c
INNER JOIN veterinarios v ON c.veterinario_id = v.id
WHERE c.status = 'concluida'
  AND YEAR(c.data_hora) = YEAR(CURDATE())
  AND MONTH(c.data_hora) = MONTH(CURDATE())
GROUP BY v.id, v.nome
ORDER BY faturamento DESC
LIMIT 1;

-- 6) Distribuição por espécie
SELECT
    e.nome AS especie,
    COUNT(a.id) AS total_animais,
    ROUND(COUNT(a.id) * 100.0 / NULLIF((SELECT COUNT(*) FROM animais), 0), 2) AS percentual
FROM especies e
LEFT JOIN animais a ON a.especie_id = e.id
GROUP BY e.id, e.nome
ORDER BY total_animais DESC;
