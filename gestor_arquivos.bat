@echo off
setlocal enabledelayedexpansion

:: =====================================
:: DETECTAR DISCO AUTOMATICAMENTE
:: =====================================
set "DISCO=%~d0"
set "BASE_DIR=%DISCO%\GestorArquivos"
set "DOCS_DIR=%BASE_DIR%\Documentos"
set "LOGS_DIR=%BASE_DIR%\Logs"
set "BACKUP_DIR=%BASE_DIR%\Backups"
set "LOG_FILE=%LOGS_DIR%\atividade.log"
set "RELATORIO=%BASE_DIR%\resumo_execucao.txt"
set "BACKUP_FILE=%BACKUP_DIR%\backup_completo.bak"

set /a pastas_criadas=0
set /a arquivos_criados=0

echo =============================================
echo   GESTOR DE ARQUIVOS - INICIALIZANDO
echo =============================================
echo.
echo Unidade detectada: %DISCO%
echo Diretório base: %BASE_DIR%
echo.

:: =====================================
:: VERIFICAR PERMISSÃO DE ESCRITA
:: =====================================
echo Verificando permissões...
> "%DISCO%\_teste_permissao.tmp" echo Teste >nul 2>&1
if exist "%DISCO%\_teste_permissao.tmp" (
    del "%DISCO%\_teste_permissao.tmp" >nul
    echo Permissão de escrita confirmada. 
) else (
    echo ERRO: Sem permissão de escrita na unidade %DISCO%. 
    echo Execute este script como Administrador ou escolha outra unidade.
    pause
    exit /b
)
echo.

:: =====================================
:: FUNÇÃO: REGISTRO DE LOG
:: =====================================
:log
set "datahora=%date% %time%"
echo [%datahora%] %~1 - %~2 >> "%LOG_FILE%"
goto :eof

:: =====================================
:: CRIAÇÃO DE DIRETÓRIOS
:: =====================================
echo Criando diretórios...
for %%D in ("%BASE_DIR%" "%DOCS_DIR%" "%LOGS_DIR%" "%BACKUP_DIR%") do (
    if not exist "%%~D" (
        mkdir "%%~D" >nul 2>&1
        if !errorlevel! equ 0 (
            set /a pastas_criadas+=1
            call :log "Criação de pasta (%%~D)" "Sucesso"
        ) else (
            call :log "Criação de pasta (%%~D)" "Falha"
        )
    ) else (
        call :log "Pasta (%%~D)" "Já existia"
    )
)

:: =====================================
:: CRIAÇÃO E ESCRITA DE ARQUIVOS
:: =====================================
echo Criando arquivos em Documentos...
(
    echo Relatório do sistema
    echo Data de geração: %date% %time%
    echo Este arquivo contém informações de execução.
) > "%DOCS_DIR%\relatorio.txt"
if !errorlevel! equ 0 (
    set /a arquivos_criados+=1
    call :log "Criação de relatorio.txt" "Sucesso"
) else (
    call :log "Criação de relatorio.txt" "Falha"
)

(
    echo id,nome,valor
    echo 1,ProdutoA,100
    echo 2,ProdutoB,200
) > "%DOCS_DIR%\dados.csv"
if !errorlevel! equ 0 (
    set /a arquivos_criados+=1
    call :log "Criação de dados.csv" "Sucesso"
) else (
    call :log "Criação de dados.csv" "Falha"
)

(
    echo [CONFIGURACOES]
    echo modo=automático
    echo versao=1.0
) > "%DOCS_DIR%\config.ini"
if !errorlevel! equ 0 (
    set /a arquivos_criados+=1
    call :log "Criação de config.ini" "Sucesso"
) else (
    call :log "Criação de config.ini" "Falha"
)

:: =====================================
:: SIMULAÇÃO DE BACKUP
:: =====================================
echo Realizando backup dos arquivos...
xcopy "%DOCS_DIR%\*" "%BACKUP_DIR%\" /Y /I >nul
if !errorlevel! lss 1 (
    call :log "Backup de arquivos para %BACKUP_DIR%" "Sucesso"
) else (
    call :log "Backup de arquivos para %BACKUP_DIR%" "Falha"
)

set "data_backup=%date% %time%"
echo Backup completo realizado em: %data_backup% > "%BACKUP_FILE%"
if !errorlevel! equ 0 (
    call :log "Criação de backup_completo.bak" "Sucesso"
) else (
    call :log "Criação de backup_completo.bak" "Falha"
)

:: =====================================
:: RELATÓRIO FINAL
:: =====================================
echo Gerando relatório final...
(
    echo RELATÓRIO DE EXECUÇÃO
    echo ----------------------
    echo Unidade de execução: %DISCO%
    echo Diretório base: %BASE_DIR%
    echo Total de arquivos criados: %arquivos_criados%
    echo Total de pastas criadas: %pastas_criadas%
    echo Data/Hora do backup: %data_backup%
) > "%RELATORIO%"

if !errorlevel! equ 0 (
    call :log "Geração do relatório resumo_execucao.txt" "Sucesso"
) else (
    call :log "Geração do relatório resumo_execucao.txt" "Falha"
)

:: =====================================
:: FINALIZAÇÃO
:: =====================================
echo.
echo =============================================
echo EXECUÇÃO CONCLUÍDA
echo ---------------------------------------------
echo Diretório base: %BASE_DIR%
echo Total de pastas criadas: %pastas_criadas%
echo Total de arquivos criados: %arquivos_criados%
echo Backup realizado em: %data_backup%
echo Log de atividades: %LOG_FILE%
echo =============================================
pause
exit /b
