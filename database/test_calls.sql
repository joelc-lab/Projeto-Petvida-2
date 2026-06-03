
USE petvida;

-- ==========================================
-- TESTES DE VALIDAÇÃO (Cenários Sucesso / Erro)
-- ==========================================

-- Teste 1: Cadastrar Animal (Sucesso) -> Vai retornar o ID criado
CALL sp_cadastrar_animal('Oliver', 2, 'Persa', '2023-01-10', 1);

-- Teste 1: Cadastrar Animal (Erro) -> Tutor inexistente (ID 999)
CALL sp_cadastrar_animal('Fantasma', 1, 'Vira-lata', '2025-05-05', 999);


-- Teste 2: Agendar Consulta (Sucesso)
CALL sp_agendar_consulta(1, 1, '2026-06-15 14:00:00', 180.00);

-- Teste 2: Agendar Consulta (Erro) -> Veterinário Ocupado no mesmo horário
CALL sp_agendar_consulta(2, 1, '2026-06-15 14:00:00', 180.00);


-- Teste 3: Registrar Pagamento (Sucesso) -> Quitando a consulta ID 1
CALL sp_registrar_pagamento(1, 'pix');

-- Teste 3: Registrar Pagamento (Erro) -> Tentando pagar de novo a mesma consulta
CALL sp_registrar_pagamento(1, 'cartao');


