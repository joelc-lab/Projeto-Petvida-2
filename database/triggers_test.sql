-- database/triggers_test.sql
-- Testes para os triggers implementados em database/triggers.sql
-- Execute este arquivo passo-a-passo (ou por seções) no client MySQL para verificar comportamento.

USE petvida;

-- 0) Limpeza/variáveis de sessão (opcional)
SET @now = NOW();

-- 1) Criar dados de teste (espécie, tutor, animal, veterinário)
INSERT INTO especies (nome) VALUES ('Especie_Teste_TRG');
SET @especie_id = LAST_INSERT_ID();

INSERT INTO tutores (nome, cpf, telefone) VALUES ('Tutor Teste TRG','999.999.999-99','0000-0000');
SET @tutor_id = LAST_INSERT_ID();

INSERT INTO animais (nome, especie_id, raca, data_nascimento, tutor_id)
VALUES ('Animal TRG', @especie_id, 'SRD', '2018-01-01', @tutor_id);
SET @animal_id = LAST_INSERT_ID();

INSERT INTO veterinarios (nome, crmv, especialidade, telefone) VALUES ('Vet TRG','CRMV-TRG','Clínica','0000');
SET @vet_id = LAST_INSERT_ID();

-- 2) Inserir uma consulta (deve acionar trg_after_insert_consulta)
INSERT INTO consultas (animal_id, veterinario_id, data_hora, valor_total)
VALUES (@animal_id, @vet_id, NOW(), 150.00);
SET @consulta_id = LAST_INSERT_ID();

-- Verificar entrada no log de auditoria para o insert da consulta
SELECT * FROM log_auditoria WHERE tabela_afetada = 'consultas' AND registro_id = @consulta_id ORDER BY data_hora DESC LIMIT 1;

-- 3) Atualizar status da consulta (deve acionar trg_after_update_consulta_status)
UPDATE consultas SET status = 'concluida' WHERE id = @consulta_id;

-- Verificar log de alteração de status
SELECT * FROM log_auditoria WHERE tabela_afetada = 'consultas' AND acao = 'UPDATE_STATUS' AND registro_id = @consulta_id ORDER BY data_hora DESC LIMIT 1;

-- 4) Testar prevenção de DELETE quando existe pagamento 'pago'
-- Inserir um pagamento marcado como 'pago'
INSERT INTO pagamentos (consulta_id, valor_pago, forma_pagamento, status, data_pagamento)
VALUES (@consulta_id, 150.00, 'pix', 'pago', NOW());
SET @pag_id = LAST_INSERT_ID();

-- Tentativa de deletar a consulta paga (esta instrução deve falhar com erro do trigger)
-- Descomente e execute manualmente para ver o erro esperado:
-- DELETE FROM consultas WHERE id = @consulta_id;

-- 5) Testar trigger BEFORE UPDATE em pagamentos: quando mudar para 'pago', preencher data_pagamento
-- Criar pagamento pendente para uma nova consulta de teste
INSERT INTO consultas (animal_id, veterinario_id, data_hora, valor_total)
VALUES (@animal_id, @vet_id, DATE_ADD(NOW(), INTERVAL 1 HOUR), 80.00);
SET @consulta2 = LAST_INSERT_ID();

INSERT INTO pagamentos (consulta_id, valor_pago, forma_pagamento, status)
VALUES (@consulta2, 0.00, 'pix', 'pendente');
SET @pag2 = LAST_INSERT_ID();

-- Atualizar status para 'pago' — o trigger deve preencher data_pagamento automaticamente
UPDATE pagamentos SET status = 'pago' WHERE id = @pag2;

-- Verificar se a data foi preenchida
SELECT id, consulta_id, status, data_pagamento FROM pagamentos WHERE id = @pag2;

-- 6) Opcional: visualizar últimos registros de log
SELECT * FROM log_auditoria ORDER BY data_hora DESC LIMIT 10;

-- 7) Limpeza (descomente para remover os dados de teste quando terminar)
-- DELETE FROM pagamentos WHERE id IN (@pag_id, @pag2);
-- DELETE FROM consultas WHERE id IN (@consulta_id, @consulta2);
-- DELETE FROM animais WHERE id = @animal_id;
-- DELETE FROM tutores WHERE id = @tutor_id;
-- DELETE FROM especies WHERE id = @especie_id;

-- Fim dos testes
