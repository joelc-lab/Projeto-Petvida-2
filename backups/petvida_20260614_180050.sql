-- ======================================================
-- BACKUP LÃ“GICO - PROJETO PETVIDA
-- Data: 14/06/2026 18:00:50
-- ======================================================
-- Este backup combina os arquivos SQL do projeto
-- Restaurar: mysql -u root -p petvida < backup.sql

-- >>> TABELAS E DADOS (petvida-v2.sql)

-- ======================================================
-- PROJETO PETVIDA - SCHEMA V2 (EXPANDIDO)
-- ======================================================

DROP DATABASE IF EXISTS petvida;
CREATE DATABASE petvida;
USE petvida;

-- 1. TABELA DE ESPECIES (NormalizaÃ§Ã£o 2NF)
CREATE TABLE especies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE
);

-- 2. TABELA DE VETERINÃRIOS
CREATE TABLE veterinarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    crmv VARCHAR(20) NOT NULL UNIQUE,
    especialidade VARCHAR(50) NOT NULL,
    telefone VARCHAR(20) NOT NULL
);

-- 3. TABELA DE TUTORES
CREATE TABLE tutores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    email VARCHAR(100),
    telefone VARCHAR(20) NOT NULL
);

-- 4. TABELA DE ANIMAIS (Alterada: especie_id FK)
CREATE TABLE animais (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    especie_id INT NOT NULL,
    raca VARCHAR(50),
    data_nascimento DATE,
    tutor_id INT NOT NULL,
    FOREIGN KEY (especie_id) REFERENCES especies(id),
    FOREIGN KEY (tutor_id) REFERENCES tutores(id)
);

-- 5. TABELA DE CONSULTAS (Adicionado Status ENUM)
CREATE TABLE consultas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    animal_id INT NOT NULL,
    veterinario_id INT NOT NULL,
    data_hora DATETIME NOT NULL,
    status ENUM('agendada', 'em_atendimento', 'concluida', 'cancelada') DEFAULT 'agendada',
    diagnostico TEXT,
    valor_total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (animal_id) REFERENCES animais(id),
    FOREIGN KEY (veterinario_id) REFERENCES veterinarios(id)
);

-- 6. TABELA DE PAGAMENTOS (Nova)
CREATE TABLE pagamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    consulta_id INT NOT NULL,
    valor_pago DECIMAL(10, 2) NOT NULL,
    forma_pagamento ENUM('pix', 'cartao', 'dinheiro', 'convenio') NOT NULL,
    data_pagamento DATETIME,
    status ENUM('pago', 'pendente', 'cancelado') DEFAULT 'pendente',
    FOREIGN KEY (consulta_id) REFERENCES consultas(id)
);

-- 7. CRIAÃ‡ÃƒO DE ÃNDICES (OtimizaÃ§Ã£o)
CREATE INDEX idx_consultas_data ON consultas(data_hora);
CREATE INDEX idx_animais_tutor ON animais(tutor_id);
CREATE INDEX idx_pagamentos_consulta ON pagamentos(consulta_id);

-- ======================================================
-- SEED DATA (POPULANDO O BANCO)
-- ======================================================

-- EspÃ©cies
INSERT INTO especies (nome) VALUES ('Cachorro'), ('Gato'), ('PÃ¡ssaro'), ('Peixe'), ('RÃ©ptil');

-- VeterinÃ¡rios (3)
INSERT INTO veterinarios (nome, crmv, especialidade, telefone) VALUES 
('Dr. Carlos Silva', 'CRMV001', 'ClÃ­nica Geral', '11911111111'),
('Dra. Ana Santos', 'CRMV002', 'Cirurgia', '11922222222'),
('Dr. Leo Costa', 'CRMV003', 'Animais ExÃ³ticos', '11933333333');

-- Tutores (8)
INSERT INTO tutores (nome, cpf, email, telefone) VALUES 
('JoÃ£o Silva', '111.111.111-11', 'joao@email.com', '99001'),
('Maria Oliveira', '222.222.222-22', 'maria@email.com', '99002'),
('Pedro Souza', '333.333.333-33', 'pedro@email.com', '99003'),
('Ana Costa', '444.444.444-44', 'ana@email.com', '99004'),
('Lucas Lima', '555.555.555-55', 'lucas@email.com', '99005'),
('Carla Dias', '666.666.666-66', 'carla@email.com', '99006'),
('Marcos Rocha', '777.777.777-77', 'marcos@email.com', '99007'),
('Julia Mendes', '888.888.888-88', 'julia@email.com', '99008');

-- Animais (15)
INSERT INTO animais (nome, especie_id, raca, tutor_id) VALUES 
('Rex', 1, 'Golden', 1), ('Thor', 1, 'Poodle', 1), ('Bolinha', 1, 'SRD', 2),
('Miau', 2, 'SiamÃªs', 2), ('Tom', 2, 'Persa', 3), ('Luna', 2, 'SRD', 3),
('Louro', 3, 'Papagaio', 4), ('Piu', 3, 'CanÃ¡rio', 4), ('Nemo', 4, 'PalhaÃ§o', 5),
('Dory', 4, 'CirurgiÃ£o', 5), ('Igu', 5, 'Iguana', 6), ('Dino', 5, 'TeiÃº', 6),
('Spyke', 1, 'Bulldog', 7), ('Mel', 1, 'Beagle', 7), ('Jade', 2, 'AngorÃ¡', 8);

-- Consultas (20)
INSERT INTO consultas (animal_id, veterinario_id, data_hora, status, valor_total) VALUES 
(1, 1, '2024-05-01 10:00', 'concluida', 150.00), (2, 1, '2024-05-01 11:00', 'concluida', 120.00),
(3, 1, '2024-05-02 09:00', 'concluida', 100.00), (4, 2, '2024-05-02 14:00', 'concluida', 350.00),
(5, 2, '2024-05-03 10:00', 'concluida', 400.00), (6, 2, '2024-05-03 15:00', 'concluida', 150.00),
(7, 3, '2024-05-04 08:00', 'concluida', 80.00), (8, 3, '2024-05-04 09:00', 'concluida', 80.00),
(9, 3, '2024-05-05 13:00', 'concluida', 50.00), (10, 3, '2024-05-05 14:00', 'concluida', 50.00),
(11, 3, '2024-05-06 10:00', 'concluida', 200.00), (12, 3, '2024-05-06 11:00', 'concluida', 180.00),
(13, 1, '2024-05-07 16:00', 'concluida', 120.00), (14, 1, '2024-05-07 17:00', 'concluida', 120.00),
(15, 2, '2024-05-08 09:00', 'concluida', 300.00), (1, 2, '2024-05-08 10:00', 'agendada', 150.00),
(2, 1, '2024-05-09 14:00', 'agendada', 100.00), (3, 1, '2024-05-09 15:00', 'cancelada', 100.00),
(4, 2, '2024-05-10 10:00', 'em_atendimento', 200.00), (5, 2, '2024-05-10 11:00', 'agendada', 200.00);

-- Pagamentos (20)
INSERT INTO pagamentos (consulta_id, valor_pago, forma_pagamento, status, data_pagamento) VALUES 
(1, 150.00, 'pix', 'pago', '2024-05-01'), (2, 120.00, 'cartao', 'pago', '2024-05-01'),
(3, 100.00, 'dinheiro', 'pago', '2024-05-02'), (4, 350.00, 'pix', 'pago', '2024-05-02'),
(5, 400.00, 'convenio', 'pago', '2024-05-03'), (6, 150.00, 'cartao', 'pago', '2024-05-03'),
(7, 80.00, 'dinheiro', 'pago', '2024-05-04'), (8, 80.00, 'pix', 'pago', '2024-05-04'),
(9, 50.00, 'pix', 'pago', '2024-05-05'), (10, 50.00, 'dinheiro', 'pago', '2024-05-05'),
(11, 200.00, 'cartao', 'pago', '2024-05-06'), (12, 180.00, 'pix', 'pago', '2024-05-06'),
(13, 120.00, 'dinheiro', 'pago', '2024-05-07'), (14, 120.00, 'cartao', 'pago', '2024-05-07'),
(15, 300.00, 'pix', 'pago', '2024-05-08'), (16, 0.00, 'pix', 'pendente', NULL),
(17, 0.00, 'cartao', 'pendente', NULL), (18, 0.00, 'dinheiro', 'cancelado', NULL),
(19, 0.00, 'pix', 'pendente', NULL), (20, 0.00, 'convenio', 'pendente', NULL);

-- >>> FUNCTIONS (functions.sql)

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
-- Soma quanto um cliente especÃ­fico jÃ¡ deixou de receita na clÃ­nica (ignora canceladas)
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
-- Retorna o histÃ³rico de idas de um animal Ã  clÃ­nica
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


-- 4) Formatador de Status com Emojis (Interface AmigÃ¡vel)
-- Deixa as tabelas do sistema visualmente incrÃ­veis e fÃ¡ceis de ler
DROP FUNCTION IF EXISTS fn_status_emoji $$
CREATE FUNCTION fn_status_emoji(p_status VARCHAR(20))
RETURNS VARCHAR(50)
DETERMINISTIC
NO SQL
BEGIN
    RETURN CASE p_status
        WHEN 'agendada' THEN 'ðŸ“… Agendada'
        WHEN 'concluida' THEN 'âœ… ConcluÃ­da'
        WHEN 'cancelada' THEN 'âŒ Cancelada'
        WHEN 'em_atendimento' THEN 'ðŸ¥ Em Atendimento'
        ELSE p_status
    END;
END $$


-- 5) Classificador de Faixa de PreÃ§o (Regra de NegÃ³cio)
-- Categoriza o tipo de atendimento com base no valor cobrado
DROP FUNCTION IF EXISTS fn_classificar_valor $$
CREATE FUNCTION fn_classificar_valor(p_valor DECIMAL(10,2))
RETURNS VARCHAR(50)
DETERMINISTIC
NO SQL
BEGIN
    RETURN CASE
        WHEN p_valor < 100.00 THEN 'Consulta Simples'
        WHEN p_valor <= 300.00 THEN 'Consulta PadrÃ£o'
        ELSE 'Procedimento Especial'
    END;
END $$

DELIMITER ;

-- >>> PROCEDURES (procedures.sql)

USE petvida;

DELIMITER $$

-- Procedure 1: Agendar consulta (insere consulta + pagamento pendente em transaÃ§Ã£o)
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
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Animal nÃ£o encontrado';
    END IF;

    -- Valida veterinÃ¡rio
    SELECT COUNT(*) INTO v_cnt FROM veterinarios WHERE id = p_veterinario_id;
    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'VeterinÃ¡rio nÃ£o encontrado';
    END IF;

    -- Verifica disponibilidade do horÃ¡rio (nÃ£o permitir se jÃ¡ existe consulta nÃ£o cancelada)
    SELECT COUNT(*) INTO v_cnt FROM consultas 
    WHERE veterinario_id = p_veterinario_id
      AND data_hora = p_data_hora
      AND status <> 'cancelada';
    IF v_cnt > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'HorÃ¡rio jÃ¡ ocupado para o veterinÃ¡rio';
    END IF;

    START TRANSACTION;
    -- Insere consulta
    INSERT INTO consultas (animal_id, veterinario_id, data_hora, valor_total)
    VALUES (p_animal_id, p_veterinario_id, p_data_hora, p_valor);
    SET v_consulta_id = LAST_INSERT_ID();

    -- Insere pagamento pendente (valor_pago 0.00, forma padrÃ£o 'pix')
    INSERT INTO pagamentos (consulta_id, valor_pago, forma_pagamento, status, data_pagamento)
    VALUES (v_consulta_id, 0.00, 'pix', 'pendente', NULL);

    COMMIT;
END$$

-- Procedure 2: Concluir consulta (atualiza status e diagnÃ³stico)
DROP PROCEDURE IF EXISTS sp_concluir_consulta$$
CREATE PROCEDURE sp_concluir_consulta(
    IN p_consulta_id INT,
    IN p_diagnostico TEXT
)
BEGIN
    DECLARE v_cnt INT;

    SELECT COUNT(*) INTO v_cnt FROM consultas WHERE id = p_consulta_id;
    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Consulta nÃ£o encontrada';
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

    -- Valida existÃªncia da consulta
    SELECT COUNT(*) INTO v_cnt FROM consultas WHERE id = p_consulta_id;
    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Consulta nÃ£o encontrada';
    END IF;

    -- Busca pagamento vinculado (verifica existÃªncia antes do SELECT INTO para evitar erro)
    SELECT COUNT(*) INTO v_cnt FROM pagamentos WHERE consulta_id = p_consulta_id;
    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pagamento nÃ£o encontrado para a consulta';
    END IF;
    SELECT id, status INTO v_pagamento_id, v_status FROM pagamentos WHERE consulta_id = p_consulta_id LIMIT 1;

    IF v_status = 'pago' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pagamento jÃ¡ realizado';
    END IF;

    -- Busca valor total da consulta
    SELECT valor_total INTO v_valor_total FROM consultas WHERE id = p_consulta_id;

    -- Atualiza pagamento
    UPDATE pagamentos
    SET status = 'pago', forma_pagamento = p_forma, data_pagamento = NOW(), valor_pago = v_valor_total
    WHERE id = v_pagamento_id;
END$$

-- Procedure 4: Cancelar consulta (transaÃ§Ã£o: consulta + pagamento)
DROP PROCEDURE IF EXISTS sp_cancelar_consulta$$
CREATE PROCEDURE sp_cancelar_consulta(
    IN p_consulta_id INT
)
BEGIN
    DECLARE v_cnt INT;

    SELECT COUNT(*) INTO v_cnt FROM consultas WHERE id = p_consulta_id;
    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Consulta nÃ£o encontrada';
    END IF;

    START TRANSACTION;
    UPDATE consultas SET status = 'cancelada' WHERE id = p_consulta_id;
    UPDATE pagamentos SET status = 'cancelado' WHERE consulta_id = p_consulta_id;
    COMMIT;
END$$

-- Procedure 5: Cadastrar animal (valida tutor e espÃ©cie) â€” retorna id criado via SELECT
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
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tutor nÃ£o encontrado';
    END IF;

    SELECT COUNT(*) INTO v_cnt FROM especies WHERE id = p_especie_id;
    IF v_cnt = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'EspÃ©cie nÃ£o encontrada';
    END IF;

    INSERT INTO animais (nome, especie_id, raca, data_nascimento, tutor_id)
    VALUES (p_nome, p_especie_id, p_raca, p_nascimento, p_tutor_id);

    SET v_new_id = LAST_INSERT_ID();

    SELECT v_new_id AS novo_id;
END$$

DELIMITER ;

-- >>> SEGURANÃ‡A (security.sql)

-- ======================================================
-- database/security.sql
-- Perfis de usuÃ¡rio e privilÃ©gios para Projeto PETVIDA
-- ======================================================

USE petvida;

-- ======================================================
-- 1. CRIAR ROLES/PERFIS DE USUÃRIO
-- ======================================================

CREATE ROLE IF NOT EXISTS 'recepcionista'@'%';
CREATE ROLE IF NOT EXISTS 'veterinario'@'%';
CREATE ROLE IF NOT EXISTS 'gerente'@'%';
CREATE ROLE IF NOT EXISTS 'admin'@'%';


-- ======================================================
-- 2. PROCEDURE HELPER: DELETE em consultas canceladas
-- ======================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_delete_consulta_cancelada$$
CREATE PROCEDURE sp_delete_consulta_cancelada(IN p_id INT)
BEGIN
    -- SÃ³ permite deletar se o status Ã© 'cancelada'
    DECLARE v_status VARCHAR(20);
    
    SELECT status INTO v_status FROM consultas WHERE id = p_id;
    
    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Consulta nÃ£o encontrada';
    END IF;
    
    IF v_status != 'cancelada' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Apenas consultas canceladas podem ser deletadas';
    END IF;
    
    -- Deleta pagamento vinculado primeiro (FK constraint)
    DELETE FROM pagamentos WHERE consulta_id = p_id;
    
    -- Deleta a consulta
    DELETE FROM consultas WHERE id = p_id;
END$$

DELIMITER ;


-- ======================================================
-- 3. PERFIL: RECEPCIONISTA
-- ======================================================
-- PermissÃµes: SELECT/INSERT em tutores, animais, consultas, especies
--             EXECUTE em sp_agendar_consulta e sp_cadastrar_animal
--             SEM DELETE, SEM acesso a pagamentos

GRANT SELECT, INSERT ON petvida.tutores TO 'recepcionista'@'%';
GRANT SELECT, INSERT ON petvida.animais TO 'recepcionista'@'%';
GRANT SELECT, INSERT ON petvida.consultas TO 'recepcionista'@'%';
GRANT SELECT, INSERT ON petvida.especies TO 'recepcionista'@'%';

-- EXECUTE nas procedures de agendamento e cadastro
GRANT EXECUTE ON PROCEDURE petvida.sp_agendar_consulta TO 'recepcionista'@'%';
GRANT EXECUTE ON PROCEDURE petvida.sp_cadastrar_animal TO 'recepcionista'@'%';

-- Sem DELETE e sem acesso a pagamentos (nÃ£o concedemos nada)


-- ======================================================
-- 4. PERFIL: VETERINÃRIO
-- ======================================================
-- PermissÃµes: SELECT em tudo
--             UPDATE em diagnostico e status da tabela consultas
--             EXECUTE em sp_concluir_consulta
--             SEM INSERT, SEM DELETE

GRANT SELECT ON petvida.* TO 'veterinario'@'%';

-- UPDATE apenas nas colunas diagnÃ³stico e status
GRANT UPDATE (diagnostico, status) ON petvida.consultas TO 'veterinario'@'%';

-- EXECUTE na procedure de conclusÃ£o
GRANT EXECUTE ON PROCEDURE petvida.sp_concluir_consulta TO 'veterinario'@'%';

-- Sem INSERT e sem DELETE


-- ======================================================
-- 5. PERFIL: GERENTE
-- ======================================================
-- PermissÃµes: SELECT/INSERT/UPDATE em tudo
--             DELETE apenas em consultas canceladas (via procedure)
--             EXECUTE em todas as procedures

GRANT SELECT, INSERT, UPDATE ON petvida.* TO 'gerente'@'%';

-- Para DELETE em consultas canceladas, usamos a procedure helper
GRANT EXECUTE ON PROCEDURE petvida.sp_delete_consulta_cancelada TO 'gerente'@'%';

-- EXECUTE em todas as procedures
GRANT EXECUTE ON PROCEDURE petvida.sp_agendar_consulta TO 'gerente'@'%';
GRANT EXECUTE ON PROCEDURE petvida.sp_concluir_consulta TO 'gerente'@'%';
GRANT EXECUTE ON PROCEDURE petvida.sp_registrar_pagamento TO 'gerente'@'%';
GRANT EXECUTE ON PROCEDURE petvida.sp_cancelar_consulta TO 'gerente'@'%';
GRANT EXECUTE ON PROCEDURE petvida.sp_cadastrar_animal TO 'gerente'@'%';


-- ======================================================
-- 6. PERFIL: ADMIN
-- ======================================================
-- PermissÃµes: ALL PRIVILEGES com GRANT OPTION

GRANT ALL PRIVILEGES ON petvida.* TO 'admin'@'%' WITH GRANT OPTION;


-- ======================================================
-- 7. EXEMPLOS: Atribuir roles a usuÃ¡rios reais
-- ======================================================
-- Descomente e ajuste os nomes de usuÃ¡rios conforme necessÃ¡rio:

-- GRANT 'recepcionista'@'%' TO 'usuario_recepcao'@'localhost';
-- GRANT 'veterinario'@'%' TO 'usuario_vet'@'localhost';
-- GRANT 'gerente'@'%' TO 'usuario_gerente'@'localhost';
-- GRANT 'admin'@'%' TO 'usuario_admin'@'localhost';

-- Ativar as roles por padrÃ£o:
-- SET DEFAULT ROLE ALL TO 'usuario_recepcao'@'localhost';
-- SET DEFAULT ROLE ALL TO 'usuario_vet'@'localhost';
-- SET DEFAULT ROLE ALL TO 'usuario_gerente'@'localhost';
-- SET DEFAULT ROLE ALL TO 'usuario_admin'@'localhost';


-- ======================================================
-- 8. REVOKE: Remover acessos da RECEPCIONISTA
-- ======================================================
-- Use este bloco para revogar todos os privilÃ©gios da recepcionista

REVOKE SELECT, INSERT ON petvida.tutores FROM 'recepcionista'@'%';
REVOKE SELECT, INSERT ON petvida.animais FROM 'recepcionista'@'%';
REVOKE SELECT, INSERT ON petvida.consultas FROM 'recepcionista'@'%';
REVOKE SELECT, INSERT ON petvida.especies FROM 'recepcionista'@'%';
REVOKE EXECUTE ON PROCEDURE petvida.sp_agendar_consulta FROM 'recepcionista'@'%';
REVOKE EXECUTE ON PROCEDURE petvida.sp_cadastrar_animal FROM 'recepcionista'@'%';

-- Remover a role por completo (descomente se necessÃ¡rio):
-- DROP ROLE 'recepcionista'@'%';


-- ======================================================
-- OBSERVAÃ‡Ã•ES IMPORTANTES:
-- ======================================================
-- 1) Este script assume que o banco de dados 'petvida' jÃ¡ existe.
--    Execute primeiro: petvida-v2.sql e procedures.sql
--
-- 2) Os nomes dos hosts ('%' = qualquer host) podem ser ajustados
--    para 'localhost' conforme sua topologia de seguranÃ§a.
--
-- 3) A restriÃ§Ã£o "DELETE apenas em consultas canceladas"
--    nÃ£o pode ser implementada por GRANT direto em SQL;
--    por isso usamos a procedure sp_delete_consulta_cancelada
--    que valida o status antes de deletar.
--
-- 4) Para usar as roles em conexÃµes reais, crie usuÃ¡rios e
--    atribua as roles usando GRANT 'role'@'host' TO 'user'@'host';
--
-- 5) Em MySQL 8.0+, vocÃª precisa ativar as roles com
--    SET DEFAULT ROLE ou SET ROLE para cada sessÃ£o.

-- >>> TRIGGERS (triggers.sql)


USE petvida;

-- 1) CRIAÃ‡ÃƒO DA TABELA DE LOG DE AUDITORIA
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
-- Registra automaticamente no log quando uma nova consulta Ã© agendada
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
-- Detecta alteraÃ§Ãµes de status e grava o histÃ³rico "de X para Y"
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
-- REGRA DE NEGÃ“CIO CRÃTICA: Impede que uma consulta jÃ¡ paga seja excluÃ­da do sistema
DROP TRIGGER IF EXISTS trg_before_delete_consulta;
CREATE TRIGGER trg_before_delete_consulta
BEFORE DELETE ON consultas
FOR EACH ROW
BEGIN
    -- Verifica se existe um pagamento concluÃ­do para esta consulta
    IF EXISTS (SELECT 1 FROM pagamentos WHERE consulta_id = OLD.id AND status = 'pago') THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Erro: Operacao cancelada. Nao e permitido excluir uma consulta com pagamento CONCLUIDO.';
    END IF;
END $$

-- d) trg_after_insert_animal (AFTER INSERT em animais)
-- Audita a entrada de novos pacientes na clÃ­nica
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
        CONCAT('Novo animal cadastrado: Nome: ', NEW.nome, ', RaÃ§a: ', IFNULL(NEW.raca, 'SRD'), ', Tutor ID: ', NEW.tutor_id)
    );
END $$

-- e) trg_before_update_pagamento (BEFORE UPDATE em pagamentos)
-- AutomaÃ§Ã£o financeira: Preenche a data automaticamente ao mudar o status para 'pago'
DROP TRIGGER IF EXISTS trg_before_update_pagamento;
CREATE TRIGGER trg_before_update_pagamento
BEFORE UPDATE ON pagamentos
FOR EACH ROW
BEGIN
    -- Se o status estÃ¡ mudando para 'pago' e antes nÃ£o era 'pago'
    IF NEW.status = 'pago' AND OLD.status <> 'pago' THEN
        SET NEW.data_pagamento = NOW();
    END IF;
END $$

DELIMITER ;

-- >>> VIEWS (views.sql)


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

-- FIM DO BACKUP

