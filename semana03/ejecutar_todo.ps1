# Autores: Miguel Rayo, Italo Rodriguez | 2026-10-27
# IA: ChatGPT/Codex para agrupar y guardar las ejecuciones.
$ErrorActionPreference='Stop'
$dir=Join-Path $PSScriptRoot 'reportes\windows'
New-Item -ItemType Directory -Force $dir | Out-Null
$sello=Get-Date -Format 'yyyyMMdd_HHmmss_fff'
& (Join-Path $PSScriptRoot 'informe_arranque.ps1')
$salida=& (Join-Path $PSScriptRoot 'talleres_windows.ps1')
$salida | Set-Content -LiteralPath (Join-Path $dir "talleres_$($env:COMPUTERNAME)_$sello.txt") -Encoding UTF8
$salida
"Resultados guardados en: $dir"
