require('dotenv').config();
const express = require('express');
const mysql = require('mysql2/promise');

const app = express();
app.use(express.json());

const pool = mysql.createPool({
  host: process.env.DB_HOST || '127.0.0.1',
  port: process.env.DB_PORT ? parseInt(process.env.DB_PORT, 10) : 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'petvida',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

const execute = async (sql, params = []) => {
  const [rows] = await pool.query(sql, params);
  return rows;
};

const callProcedure = async (procedureName, params = []) => {
  const placeholders = params.map(() => '?').join(', ');
  const sql = `CALL ${procedureName}(${placeholders})`;
  const [result] = await pool.query(sql, params);
  return result;
};

app.get('/api/veterinarios', async (req, res) => {
  try {
    const veterinarios = await execute(
      'SELECT id, nome, crmv, especialidade, telefone FROM veterinarios ORDER BY nome'
    );
    res.json(veterinarios);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/animais', async (req, res) => {
  try {
    const animais = await execute('SELECT * FROM vw_animais_detalhados ORDER BY tutor, animal');
    res.json(animais);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/agenda/:data', async (req, res) => {
  try {
    const { data } = req.params;
    if (!/^\d{4}-\d{2}-\d{2}$/.test(data)) {
      return res.status(400).json({ error: 'Data deve estar no formato YYYY-MM-DD' });
    }
    const agenda = await execute(
      'SELECT * FROM vw_consultas_completas WHERE DATE(data_hora) = ? ORDER BY data_hora',
      [data]
    );
    res.json(agenda);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/consultas', async (req, res) => {
  try {
    const { animal_id, veterinario_id, data_hora, valor } = req.body;
    if (!animal_id || !veterinario_id || !data_hora || valor == null) {
      return res.status(400).json({
        error: 'Campos obrigatórios: animal_id, veterinario_id, data_hora, valor',
      });
    }
    await callProcedure('sp_agendar_consulta', [animal_id, veterinario_id, data_hora, valor]);
    res.status(201).json({ message: 'Consulta agendada com sucesso' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.put('/api/consultas/:id/concluir', async (req, res) => {
  try {
    const consultaId = Number(req.params.id);
    const { diagnostico } = req.body;
    if (!consultaId || !diagnostico) {
      return res.status(400).json({ error: 'Consulta inválida ou diagnóstico ausente' });
    }
    await callProcedure('sp_concluir_consulta', [consultaId, diagnostico]);
    res.json({ message: 'Consulta concluída com sucesso' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/api/pagamentos/:consulta_id', async (req, res) => {
  try {
    const consultaId = Number(req.params.consulta_id);
    const { forma } = req.body;
    if (!consultaId || !forma) {
      return res.status(400).json({ error: 'Consulta inválida ou forma de pagamento ausente' });
    }
    await callProcedure('sp_registrar_pagamento', [consultaId, forma]);
    res.status(201).json({ message: 'Pagamento registrado com sucesso' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/relatorios/dashboard', async (req, res) => {
  try {
    const query = `
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
        SELECT consulta_id, MAX(status) AS status, SUM(valor_pago) AS valor_pago
        FROM pagamentos
        GROUP BY consulta_id
      ) p ON c.id = p.consulta_id
      WHERE c.status = 'concluida'
    `;
    const dashboard = await execute(query);
    res.json(dashboard[0] || {});
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/relatorios/inadimplentes', async (req, res) => {
  try {
    const inadimplentes = await execute(
      'SELECT * FROM vw_inadimplentes ORDER BY data_hora DESC'
    );
    res.json(inadimplentes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint não encontrado' });
});

const port = Number(process.env.PORT) || 3000;
app.listen(port, () => {
  console.log(`PetVida API rodando em http://localhost:${port}`);
});
