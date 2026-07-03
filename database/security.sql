-- ======================================================
-- database/security.sql
-- Perfis de usuário e privilégios para Projeto PETVIDA
-- ======================================================

USE petvida;

-- ======================================================
-- 1. CRIAR ROLES/PERFIS DE USUÁRIO
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
    -- Só permite deletar se o status é 'cancelada'
    DECLARE v_status VARCHAR(20);
    
    SELECT status INTO v_status FROM consultas WHERE id = p_id;
    
    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Consulta não encontrada';
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
-- Permissões: SELECT/INSERT em tutores, animais, consultas, especies
--             EXECUTE em sp_agendar_consulta e sp_cadastrar_animal
--             SEM DELETE, SEM acesso a pagamentos

GRANT SELECT, INSERT ON petvida.tutores TO 'recepcionista'@'%';
GRANT SELECT, INSERT ON petvida.animais TO 'recepcionista'@'%';
GRANT SELECT, INSERT ON petvida.consultas TO 'recepcionista'@'%';
GRANT SELECT, INSERT ON petvida.especies TO 'recepcionista'@'%';

-- EXECUTE nas procedures de agendamento e cadastro
GRANT EXECUTE ON PROCEDURE petvida.sp_agendar_consulta TO 'recepcionista'@'%';
GRANT EXECUTE ON PROCEDURE petvida.sp_cadastrar_animal TO 'recepcionista'@'%';

-- Sem DELETE e sem acesso a pagamentos (não concedemos nada)


-- ======================================================
-- 4. PERFIL: VETERINÁRIO
-- ======================================================
-- Permissões: SELECT em tudo
--             UPDATE em diagnostico e status da tabela consultas
--             EXECUTE em sp_concluir_consulta
--             SEM INSERT, SEM DELETE

GRANT SELECT ON petvida.* TO 'veterinario'@'%';

-- UPDATE apenas nas colunas diagnóstico e status
GRANT UPDATE (diagnostico, status) ON petvida.consultas TO 'veterinario'@'%';

-- EXECUTE na procedure de conclusão
GRANT EXECUTE ON PROCEDURE petvida.sp_concluir_consulta TO 'veterinario'@'%';

-- Sem INSERT e sem DELETE


-- ======================================================
-- 5. PERFIL: GERENTE
-- ======================================================
-- Permissões: SELECT/INSERT/UPDATE em tudo
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
-- Permissões: ALL PRIVILEGES com GRANT OPTION

GRANT ALL PRIVILEGES ON petvida.* TO 'admin'@'%' WITH GRANT OPTION;


-- ======================================================
-- 7. EXEMPLOS: Atribuir roles a usuários reais
-- ======================================================
-- Descomente e ajuste os nomes de usuários conforme necessário:

-- GRANT 'recepcionista'@'%' TO 'usuario_recepcao'@'localhost';
-- GRANT 'veterinario'@'%' TO 'usuario_vet'@'localhost';
-- GRANT 'gerente'@'%' TO 'usuario_gerente'@'localhost';
-- GRANT 'admin'@'%' TO 'usuario_admin'@'localhost';

-- Ativar as roles por padrão:
-- SET DEFAULT ROLE ALL TO 'usuario_recepcao'@'localhost';
-- SET DEFAULT ROLE ALL TO 'usuario_vet'@'localhost';
-- SET DEFAULT ROLE ALL TO 'usuario_gerente'@'localhost';
-- SET DEFAULT ROLE ALL TO 'usuario_admin'@'localhost';


-- ======================================================
-- 8. REVOKE: Remover acessos da RECEPCIONISTA
-- ======================================================
-- Use este bloco para revogar todos os privilégios da recepcionista

REVOKE SELECT, INSERT ON petvida.tutores FROM 'recepcionista'@'%';
REVOKE SELECT, INSERT ON petvida.animais FROM 'recepcionista'@'%';
REVOKE SELECT, INSERT ON petvida.consultas FROM 'recepcionista'@'%';
REVOKE SELECT, INSERT ON petvida.especies FROM 'recepcionista'@'%';
REVOKE EXECUTE ON PROCEDURE petvida.sp_agendar_consulta FROM 'recepcionista'@'%';
REVOKE EXECUTE ON PROCEDURE petvida.sp_cadastrar_animal FROM 'recepcionista'@'%';

-- Remover a role por completo (descomente se necessário):
-- DROP ROLE 'recepcionista'@'%';


-- ======================================================
-- OBSERVAÇÕES IMPORTANTES:
-- ======================================================
-- 1) Este script assume que o banco de dados 'petvida' já existe.
--    Execute primeiro: petvida-v2.sql e procedures.sql
--
-- 2) Os nomes dos hosts ('%' = qualquer host) podem ser ajustados
--    para 'localhost' conforme sua topologia de segurança.
--
-- 3) A restrição "DELETE apenas em consultas canceladas"
--    não pode ser implementada por GRANT direto em SQL;
--    por isso usamos a procedure sp_delete_consulta_cancelada
--    que valida o status antes de deletar.
--
-- 4) Para usar as roles em conexões reais, crie usuários e
--    atribua as roles usando GRANT 'role'@'host' TO 'user'@'host';
--
-- 5) Em MySQL 8.0+, você precisa ativar as roles com
--    SET DEFAULT ROLE ou SET ROLE para cada sessão.
