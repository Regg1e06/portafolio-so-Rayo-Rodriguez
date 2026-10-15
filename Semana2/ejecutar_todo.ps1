# Ejecuta reporte y demos Windows, con una captura independiente por script.
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$destino = Join-Path $PSScriptRoot 'reportes/windows'
New-Item -ItemType Directory -Force -Path $destino | Out-Null
$lineas = & {
    'EJECUCION COMPLETA - SEMANA 2 - WINDOWS'
    & (Join-Path $PSScriptRoot 'memoria.ps1') -DirectorioSalida $destino
    & (Join-Path $PSScriptRoot 'clases/demo_clase.ps1') -DirectorioSalida $destino
    if (Get-Command gcc -ErrorAction SilentlyContinue) {
        & (Join-Path $PSScriptRoot 'clases/demo_matriz.ps1') -DirectorioSalida $destino
    } else { 'PENDIENTE: GCC no esta en PATH; la demo opcional de matriz no se ejecuto.' }
}
$lineas | Out-File -LiteralPath (Join-Path $destino 'salida_todo_windows.txt') -Encoding utf8 -Width 200
$lineas
