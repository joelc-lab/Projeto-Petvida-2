# database/backup.ps1
# Script de backup do PETVIDA

param(
    [string]$User = "root",
    [string]$Password = "",
    [string]$DbHost = "localhost",
    [string]$DbName = "petvida"
)

# Caminhos possíveis do MySQL
$mysqlPaths = @(
    "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe",
    "C:\Program Files (x86)\MySQL\MySQL Server 8.0\bin\mysqldump.exe",
    "C:\MySQL\bin\mysqldump.exe"
)

$mysqldump = $null
foreach ($path in $mysqlPaths) {
    if (Test-Path $path) {
        $mysqldump = $path
        break
    }
}

if (-not $mysqldump) {
    Write-Host "Erro: mysqldump não encontrado. Verifique a instalação do MySQL."
    exit 1
}

$backupDir = Join-Path (Split-Path $PSCommandPath) "..\backups"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = Join-Path $backupDir "${DbName}_${timestamp}.sql"

if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    Write-Host "Diretório criado: $backupDir"
}

Write-Host "Iniciando backup do banco '$DbName'..."
Write-Host "Arquivo: $backupFile"

$cmd = @('&', $mysqldump, '-u', $User, '-h', $DbHost, $DbName)
if ($Password) {
    $cmd += "-p$Password"
}

& $mysqldump -u $User -h $DbHost $DbName | Out-File -Encoding UTF8 $backupFile

if ((Get-Item $backupFile).Length -gt 0) {
    $size = (Get-Item $backupFile).Length
    Write-Host "Backup realizado com sucesso!"
    Write-Host "Tamanho: $(($size / 1KB).ToString('F2')) KB"
}
else {
    Write-Host "Aviso: Arquivo de backup vazio."
}

Write-Host ""
Write-Host "Últimos backups:"
Get-ChildItem $backupDir -File | Sort-Object LastWriteTime -Descending | Select-Object -First 5
