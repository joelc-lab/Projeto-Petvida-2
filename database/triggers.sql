
USE petvida;

-- 1) CRIAÇÃO DA TABELA DE LOG DE AUDITORIA
CREATE TABLE IF NOT EXISTS log_auditoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tabela_afetada VARCHAR(50) NOT NULL,
    acao VARCHAR(20) NOT NULL,
    registro_id INT NOT NULL,
    detalhes TEXT,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER $$

-- a) trg_after_insert_consulta (AFTER INSERT em consultas)
-- Registra automaticamente no log quando uma nova consulta é agendada
DROP TRIGGER IF EXISTS trg_after_insert_consulta;
CREATE TRIGGER trg_after_insert_consulta
AFTER INSERT ON consultas
FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabela_afetada, acao, registro_id, detalhes)
    VALUES (
        'consultas', 
        'INSERT', 
        NEW.id, 
        CONCAT('Nova consulta criada para o Animal ID: ', NEW.animal_id, ', Vet ID: ', NEW.veterinario_id, ' em ', NEW.data_hora)
    );
END $$

-- b) trg_after_update_consulta_status (AFTER UPDATE em consultas)
-- Detecta alterações de status e grava o histórico "de X para Y"
DROP TRIGGER IF EXISTS trg_after_update_consulta_status;
CREATE TRIGGER trg_after_update_consulta_status
AFTER UPDATE ON consultas
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO log_auditoria (tabela_afetada, acao, registro_id, detalhes)
        VALUES (
            'consultas', 
            'UPDATE_STATUS', 
            NEW.id, 
            CONCAT('Status alterado de \'', OLD.status, '\' para \'', NEW.status, '\'')
        );
    END IF;
END $$

-- c) trg_before_delete_consulta (BEFORE DELETE em consultas)
-- REGRA DE NEGÓCIO CRÍTICA: Impede que uma consulta já paga seja excluída do sistema
DROP TRIGGER IF EXISTS trg_before_delete_consulta;
CREATE TRIGGER trg_before_delete_consulta
BEFORE DELETE ON consultas
FOR EACH ROW
BEGIN
    -- Verifica se existe um pagamento concluído para esta consulta
    IF EXISTS (SELECT 1 FROM pagamentos WHERE consulta_id = OLD.id AND status = 'pago') THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Erro: Operacao cancelada. Nao e permitido excluir uma consulta com pagamento CONCLUIDO.';
    END IF;
END $$

-- d) trg_after_insert_animal (AFTER INSERT em animais)
-- Audita a entrada de novos pacientes na clínica
DROP TRIGGER IF EXISTS trg_after_insert_animal;
CREATE TRIGGER trg_after_insert_animal
AFTER INSERT ON animais
FOR EACH ROW
BEGIN
    INSERT INTO log_auditoria (tabela_afetada, acao, registro_id, detalhes)
    VALUES (
        'animais', 
        'INSERT', 
        NEW.id, 
        CONCAT('Novo animal cadastrado: Nome: ', NEW.nome, ', Raça: ', IFNULL(NEW.raca, 'SRD'), ', Tutor ID: ', NEW.tutor_id)
    );
END $$

-- e) trg_before_update_pagamento (BEFORE UPDATE em pagamentos)
-- Automação financeira: Preenche a data automaticamente ao mudar o status para 'pago'
DROP TRIGGER IF EXISTS trg_before_update_pagamento;
CREATE TRIGGER trg_before_update_pagamento
BEFORE UPDATE ON pagamentos
FOR EACH ROW
BEGIN
    -- Se o status está mudando para 'pago' e antes não era 'pago'
    IF NEW.status = 'pago' AND OLD.status <> 'pago' THEN
        SET NEW.data_pagamento = NOW();
    END IF;
END $$

DELIMITER ;