# Criar backup consolidando todos os arquivos SQL
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "C:\Users\Joel\Documents\Projeto-Petvida-2\backups\petvida_$timestamp.sql"
$dbDir = "C:\Users\Joel\Documents\Projeto-Petvida-2\database"

$header = @"
-- ======================================================
-- BACKUP LÓGICO - PROJETO PETVIDA
-- Data: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')
-- ======================================================
-- Este backup combina os arquivos SQL do projeto
-- Restaurar: mysql -u root -p petvida < backup.sql

"@

$header | Out-File -Encoding UTF8 $backupFile

# Adicionar cada arquivo SQL
"-- >>> TABELAS E DADOS (petvida-v2.sql)`n" | Out-File -Encoding UTF8 -Append $backupFile
Get-Content "$dbDir\petvida-v2.sql" | Out-File -Encoding UTF8 -Append $backupFile

"`n-- >>> FUNCTIONS (functions.sql)`n" | Out-File -Encoding UTF8 -Append $backupFile
Get-Content "$dbDir\functions.sql" | Out-File -Encoding UTF8 -Append $backupFile

"`n-- >>> PROCEDURES (procedures.sql)`n" | Out-File -Encoding UTF8 -Append $backupFile
Get-Content "$dbDir\procedures.sql" | Out-File -Encoding UTF8 -Append $backupFile

"`n-- >>> SEGURANÇA (security.sql)`n" | Out-File -Encoding UTF8 -Append $backupFile
Get-Content "$dbDir\security.sql" | Out-File -Encoding UTF8 -Append $backupFile

"`n-- >>> TRIGGERS (triggers.sql)`n" | Out-File -Encoding UTF8 -Append $backupFile
Get-Content "$dbDir\triggers.sql" | Out-File -Encoding UTF8 -Append $backupFile

"`n-- >>> VIEWS (views.sql)`n" | Out-File -Encoding UTF8 -Append $backupFile
Get-Content "$dbDir\views.sql" | Out-File -Encoding UTF8 -Append $backupFile

"`n-- FIM DO BACKUP`n" | Out-File -Encoding UTF8 -Append $backupFile

$size = (Get-Item $backupFile).Length
$sizeKB = [math]::Round($size / 1KB, 2)
Write-Host "Backup criado com sucesso!"
Write-Host "Arquivo: $backupFile"
Write-Host "Tamanho: $sizeKB KB"
