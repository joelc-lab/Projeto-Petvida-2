USE petvida;

DELIMITER $$

-- Procedure 1: Agendar consulta (insere consulta + pagamento pendente em transação)
DROP PROCEDURE IF EXISTS sp_agendar_consulta$$
CREATE PROCEDURE sp_agendar_consulta(
    IN p_animal_id INT,
    IN p_veterinario_id INT,
    IN p_data_hora DATETIME,
    IN p_valor DECIMAL(10,2)
)
BEGIN
    DECLARE v_cnt INT;
    DECLARE v_consulta_id INT;

    -- Valida animal
    SELECT COUNT(*) INTO v_cnt FROM animais WHERE id = p_animal_id;
    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Animal não encontrado';
    END IF;

    -- Valida veterinário
    SELECT COUNT(*) INTO v_cnt FROM veterinarios WHERE id = p_veterinario_id;
    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Veterinário não encontrado';
    END IF;

    -- Verifica disponibilidade do horário (não permitir se já existe consulta não cancelada)
    SELECT COUNT(*) INTO v_cnt FROM consultas 
    WHERE veterinario_id = p_veterinario_id
      AND data_hora = p_data_hora
      AND status <> 'cancelada';
    IF v_cnt > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Horário já ocupado para o veterinário';
    END IF;

    START TRANSACTION;
    -- Insere consulta
    INSERT INTO consultas (animal_id, veterinario_id, data_hora, valor_total)
    VALUES (p_animal_id, p_veterinario_id, p_data_hora, p_valor);
    SET v_consulta_id = LAST_INSERT_ID();

    -- Insere pagamento pendente (valor_pago 0.00, forma padrão 'pix')
    INSERT INTO pagamentos (consulta_id, valor_pago, forma_pagamento, status, data_pagamento)
    VALUES (v_consulta_id, 0.00, 'pix', 'pendente', NULL);

    COMMIT;
END$$

-- Procedure 2: Concluir consulta (atualiza status e diagnóstico)
DROP PROCEDURE IF EXISTS sp_concluir_consulta$$
CREATE PROCEDURE sp_concluir_consulta(
    IN p_consulta_id INT,
    IN p_diagnostico TEXT
)
BEGIN
    DECLARE v_cnt INT;

    SELECT COUNT(*) INTO v_cnt FROM consultas WHERE id = p_consulta_id;
    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Consulta não encontrada';
    END IF;

    UPDATE consultas
    SET status = 'concluida', diagnostico = p_diagnostico
    WHERE id = p_consulta_id;
END$$

-- Procedure 3: Registrar pagamento (marca pagamento como 'pago')
DROP PROCEDURE IF EXISTS sp_registrar_pagamento$$
CREATE PROCEDURE sp_registrar_pagamento(
    IN p_consulta_id INT,
    IN p_forma VARCHAR(20)
)
BEGIN
    DECLARE v_cnt INT;
    DECLARE v_pagamento_id INT;
    DECLARE v_status VARCHAR(20);
    DECLARE v_valor_total DECIMAL(10,2);

    -- Valida existência da consulta
    SELECT COUNT(*) INTO v_cnt FROM consultas WHERE id = p_consulta_id;
    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Consulta não encontrada';
    END IF;

    -- Busca pagamento vinculado (verifica existência antes do SELECT INTO para evitar erro)
    SELECT COUNT(*) INTO v_cnt FROM pagamentos WHERE consulta_id = p_consulta_id;
    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pagamento não encontrado para a consulta';
    END IF;
    SELECT id, status INTO v_pagamento_id, v_status FROM pagamentos WHERE consulta_id = p_consulta_id LIMIT 1;

    IF v_status = 'pago' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pagamento já realizado';
    END IF;

    -- Busca valor total da consulta
    SELECT valor_total INTO v_valor_total FROM consultas WHERE id = p_consulta_id;

    -- Atualiza pagamento
    UPDATE pagamentos
    SET status = 'pago', forma_pagamento = p_forma, data_pagamento = NOW(), valor_pago = v_valor_total
    WHERE id = v_pagamento_id;
END$$

-- Procedure 4: Cancelar consulta (transação: consulta + pagamento)
DROP PROCEDURE IF EXISTS sp_cancelar_consulta$$
CREATE PROCEDURE sp_cancelar_consulta(
    IN p_consulta_id INT
)
BEGIN
    DECLARE v_cnt INT;

    SELECT COUNT(*) INTO v_cnt FROM consultas WHERE id = p_consulta_id;
    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Consulta não encontrada';
    END IF;

    START TRANSACTION;
    UPDATE consultas SET status = 'cancelada' WHERE id = p_consulta_id;
    UPDATE pagamentos SET status = 'cancelado' WHERE consulta_id = p_consulta_id;
    COMMIT;
END$$

-- Procedure 5: Cadastrar animal (valida tutor e espécie) — retorna id criado via SELECT
DROP PROCEDURE IF EXISTS sp_cadastrar_animal$$
CREATE PROCEDURE sp_cadastrar_animal(
    IN p_nome VARCHAR(100),
    IN p_especie_id INT,
    IN p_raca VARCHAR(50),
    IN p_nascimento DATE,
    IN p_tutor_id INT
)
BEGIN
    DECLARE v_cnt INT;
    DECLARE v_new_id INT;

    SELECT COUNT(*) INTO v_cnt FROM tutores WHERE id = p_tutor_id;
    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tutor não encontrado';
    END IF;

    SELECT COUNT(*) INTO v_cnt FROM especies WHERE id = p_especie_id;
    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Espécie não encontrada';
    END IF;

    INSERT INTO animais (nome, especie_id, raca, data_nascimento, tutor_id)
    VALUES (p_nome, p_especie_id, p_raca, p_nascimento, p_tutor_id);

    SET v_new_id = LAST_INSERT_ID();

    SELECT v_new_id AS novo_id;
END$$

DELIMITER ;
