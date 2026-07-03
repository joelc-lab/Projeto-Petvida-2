#!/bin/bash

# ======================================================
# database/backup.sh
# Script para realizar backup automático do banco PETVIDA
# Uso: bash backup.sh [user] [password] [host]
# ======================================================

# Valores padrão
DB_USER="${1:-root}"
DB_PASS="${2:-}"
DB_HOST="${3:-localhost}"
DB_NAME="petvida"
BACKUP_DIR="$(dirname "$0")/../backups"

# Gerar timestamp no formato: YYYYMMDD_HHMMSS
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${TIMESTAMP}.sql"

# Criar diretório de backup se não existir
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "✓ Diretório de backup criado: $BACKUP_DIR"
fi

# Executar mysqldump
echo "Iniciando backup do banco '$DB_NAME'..."
echo "Arquivo de destino: $BACKUP_FILE"

if [ -z "$DB_PASS" ]; then
    # Sem password (usar socket)
    mysqldump -u "$DB_USER" -h "$DB_HOST" "$DB_NAME" > "$BACKUP_FILE"
else
    # Com password
    mysqldump -u "$DB_USER" -p"$DB_PASS" -h "$DB_HOST" "$DB_NAME" > "$BACKUP_FILE"
fi

# Verificar se o backup foi bem-sucedido
if [ $? -eq 0 ]; then
    SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    LINES=$(wc -l < "$BACKUP_FILE")
    echo "✓ Backup concluído com sucesso!"
    echo "  - Arquivo: $BACKUP_FILE"
    echo "  - Tamanho: $SIZE"
    echo "  - Linhas: $LINES"
else
    echo "✗ Erro ao realizar o backup!"
    exit 1
fi

# Listar últimos 5 backups
echo ""
echo "Últimos backups:"
ls -lh "$BACKUP_DIR" | tail -6
