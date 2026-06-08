USE petvida;

DELIMITER $$

-- 1) Calcular Idade Detalhada do Animal
-- Transforma uma data fria em uma resposta humana ("X anos e Y meses")
DROP FUNCTION IF EXISTS fn_idade_animal $$
CREATE FUNCTION fn_idade_animal(p_data_nascimento DATE)
RETURNS VARCHAR(100)
DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_anos INT;
    DECLARE v_meses INT;

    SET v_anos = TIMESTAMPDIFF(YEAR, p_data_nascimento, CURDATE());
    SET v_meses = TIMESTAMPDIFF(MONTH, p_data_nascimento, CURDATE()) % 12;

    RETURN CONCAT(v_anos, ' anos e ', v_meses, ' meses');
END $$


-- 2) Faturamento por Tutor
-- Soma quanto um cliente específico já deixou de receita na clínica (ignora canceladas)
DROP FUNCTION IF EXISTS fn_total_gasto_tutor $$
CREATE FUNCTION fn_total_gasto_tutor(p_tutor_id INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
NOT DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10,2);

    SELECT IFNULL(SUM(c.valor_total), 0.00) INTO v_total
    FROM consultas c
    INNER JOIN animais a ON c.animal_id = a.id
    WHERE a.tutor_id = p_tutor_id AND c.status != 'cancelada';

    RETURN v_total;
END $$


-- 3) Contador de Consultas do Paciente
-- Retorna o histórico de idas de um animal à clínica
DROP FUNCTION IF EXISTS fn_qtd_consultas_animal $$
CREATE FUNCTION fn_qtd_consultas_animal(p_animal_id INT)
RETURNS INT
READS SQL DATA
NOT DETERMINISTIC
BEGIN
    DECLARE v_qtd INT;

    SELECT COUNT(*) INTO v_qtd
    FROM consultas
    WHERE animal_id = p_animal_id;

    RETURN v_qtd;
END $$


-- 4) Formatador de Status com Emojis (Interface Amigável)
-- Deixa as tabelas do sistema visualmente incríveis e fáceis de ler
DROP FUNCTION IF EXISTS fn_status_emoji $$
CREATE FUNCTION fn_status_emoji(p_status VARCHAR(20))
RETURNS VARCHAR(50)
DETERMINISTIC
NO SQL
BEGIN
    RETURN CASE p_status
        WHEN 'agendada' THEN '📅 Agendada'
        WHEN 'concluida' THEN '✅ Concluída'
        WHEN 'cancelada' THEN '❌ Cancelada'
        WHEN 'em_atendimento' THEN '🏥 Em Atendimento'
        ELSE p_status
    END;
END $$


-- 5) Classificador de Faixa de Preço (Regra de Negócio)
-- Categoriza o tipo de atendimento com base no valor cobrado
DROP FUNCTION IF EXISTS fn_classificar_valor $$
CREATE FUNCTION fn_classificar_valor(p_valor DECIMAL(10,2))
RETURNS VARCHAR(50)
DETERMINISTIC
NO SQL
BEGIN
    RETURN CASE
        WHEN p_valor < 100.00 THEN 'Consulta Simples'
        WHEN p_valor <= 300.00 THEN 'Consulta Padrão'
        ELSE 'Procedimento Especial'
    END;
END $$

DELIMITER ;