-- ======================================================
-- PROJETO PETVIDA - SCHEMA V2 (EXPANDIDO)
-- ======================================================

DROP DATABASE IF EXISTS petvida;
CREATE DATABASE petvida;
USE petvida;

-- 1. TABELA DE ESPECIES (Normalização 2NF)
CREATE TABLE especies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE
);

-- 2. TABELA DE VETERINÁRIOS
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

-- 7. CRIAÇÃO DE ÍNDICES (Otimização)
CREATE INDEX idx_consultas_data ON consultas(data_hora);
CREATE INDEX idx_animais_tutor ON animais(tutor_id);
CREATE INDEX idx_pagamentos_consulta ON pagamentos(consulta_id);

-- ======================================================
-- SEED DATA (POPULANDO O BANCO)
-- ======================================================

-- Espécies
INSERT INTO especies (nome) VALUES ('Cachorro'), ('Gato'), ('Pássaro'), ('Peixe'), ('Réptil');

-- Veterinários (3)
INSERT INTO veterinarios (nome, crmv, especialidade, telefone) VALUES 
('Dr. Carlos Silva', 'CRMV001', 'Clínica Geral', '11911111111'),
('Dra. Ana Santos', 'CRMV002', 'Cirurgia', '11922222222'),
('Dr. Leo Costa', 'CRMV003', 'Animais Exóticos', '11933333333');

-- Tutores (8)
INSERT INTO tutores (nome, cpf, email, telefone) VALUES 
('João Silva', '111.111.111-11', 'joao@email.com', '99001'),
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
('Miau', 2, 'Siamês', 2), ('Tom', 2, 'Persa', 3), ('Luna', 2, 'SRD', 3),
('Louro', 3, 'Papagaio', 4), ('Piu', 3, 'Canário', 4), ('Nemo', 4, 'Palhaço', 5),
('Dory', 4, 'Cirurgião', 5), ('Igu', 5, 'Iguana', 6), ('Dino', 5, 'Teiú', 6),
('Spyke', 1, 'Bulldog', 7), ('Mel', 1, 'Beagle', 7), ('Jade', 2, 'Angorá', 8);

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