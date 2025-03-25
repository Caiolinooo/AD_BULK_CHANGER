@echo off
title Gerenciador de Permissões em Massa para AD - Inicialização
echo.
echo ============================================================
echo   Gerenciador de Permissões em Massa para Active Directory
echo ============================================================
echo.
echo Verificando privilégios de administrador...

net session >nul 2>&1
if %errorLevel% == 0 (
    echo Privilégios administrativos confirmados.
) else (
    echo AVISO: Este aplicativo requer privilégios administrativos.
    echo Solicitando elevação de privilégios...
    echo.
)

echo Iniciando aplicação. Por favor, aguarde...
PowerShell -Command "Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -NoProfile -File \"%~dp0BulkPermissionAD.ps1\"' -Verb RunAs"

if %errorLevel% neq 0 (
    echo.
    echo ERRO: Não foi possível iniciar a aplicação com privilégios administrativos.
    echo Verifique se você confirmou o prompt de elevação de privilégios.
    echo.
    pause
    exit /b 1
)

exit /b 0