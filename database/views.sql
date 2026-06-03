
USE petvida;

-- 1) 

CREATE OR REPLACE VIEW vw_consultas_completas AS
SELECT 
    c.data_hora,
    c.status AS status_consulta,
    c.diagnostico,
    c.valor_total AS valor_consulta,
    a.nome AS animal,
    e.nome AS especie,
    t.nome AS tutor,
    t.telefone AS telefone_tutor,
    v.nome AS veterinario,
    v.especialidade,
    p.forma_pagamento,
    p.status AS status_pagamento
FROM consultas c
INNER JOIN animais a ON c.animal_id = a.id
INNER JOIN especies e ON a.especie_id = e.id
INNER JOIN tutores t ON a.tutor_id = t.id
INNER JOIN veterinarios v ON c.veterinario_id = v.id
LEFT JOIN pagamentos p ON c.id = p.consulta_id;

-- 2) 
CREATE OR REPLACE VIEW vw_agenda_hoje AS
SELECT 
    TIME(data_hora) AS hora,
    animal,
    tutor,
    veterinario,
    status_consulta
FROM vw_consultas_completas
WHERE DATE(data_hora) = CURDATE()
ORDER BY data_hora ASC;

-- 3) 
CREATE OR REPLACE VIEW vw_faturamento_mensal AS
SELECT 
    YEAR(data_hora) AS ano,
    MONTH(data_hora) AS mes,
    veterinario,
    COUNT(*) AS total_atendimentos,
    SUM(valor_consulta) AS faturamento_total
FROM vw_consultas_completas
WHERE status_consulta = 'concluida'
GROUP BY ano, mes, veterinario;

-- 4) 
CREATE OR REPLACE VIEW vw_animais_detalhados AS
SELECT 
    a.nome AS animal,
    t.nome AS tutor,
    e.nome AS especie,
    COUNT(c.id) AS total_consultas
FROM animais a
INNER JOIN tutores t ON a.tutor_id = t.id
INNER JOIN especies e ON a.especie_id = e.id
LEFT JOIN consultas c ON a.id = c.animal_id
GROUP BY a.id, a.nome, t.nome, e.nome;

-- 5)
CREATE OR REPLACE VIEW vw_inadimplentes AS
SELECT 
    data_hora,
    animal,
    tutor,
    telefone_tutor,
    valor_consulta,
    IFNULL(status_pagamento, 'Sem Registro') AS status_pagamento
FROM vw_consultas_completas
WHERE status_consulta = 'concluida' 
  AND (status_pagamento = 'pendente' OR status_pagamento IS NULL);