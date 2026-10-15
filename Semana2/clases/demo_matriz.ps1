# Compila y ejecuta ambos recorridos en Windows; requiere GCC en PATH.
[CmdletBinding()]
param([string]$Gcc = 'gcc', [string]$DirectorioSalida = (Join-Path (Split-Path $PSScriptRoot -Parent) 'reportes/windows'))
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $DirectorioSalida | Out-Null
$generados = Join-Path $PSScriptRoot 'generados'
New-Item -ItemType Directory -Force -Path $generados | Out-Null
$compilador = (Get-Command $Gcc -ErrorAction Stop).Source
$binario = Join-Path $generados 'matriz.exe'
& $compilador -std=c11 -Wall -Wextra -O0 (Join-Path $PSScriptRoot 'matriz.c') -o $binario
if ($LASTEXITCODE -ne 0) { throw 'No se pudo compilar matriz.c' }
$captura = & {
    'DEMO MATRIZ - MEDICION REAL EN WINDOWS'
    "Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
    (& $compilador --version | Select-Object -First 1)
    'Compilacion: gcc -std=c11 -Wall -Wextra -O0 matriz.c -o matriz.exe'
    'Tiempo informado por clock()/CLOCKS_PER_SEC; no confundir con Tmedio simulado.'
    'Una ejecucion por recorrido; tiempos sujetos a carga y hardware.'
    & $binario
    if ($LASTEXITCODE -ne 0) { throw 'La suma por filas no coincide con el valor esperado.' }
    & $binario c
    if ($LASTEXITCODE -ne 0) { throw 'La suma por columnas no coincide con el valor esperado.' }
    'Suma esperada en ambos recorridos: 68702699520.'
}
$captura | Out-File -LiteralPath (Join-Path $DirectorioSalida 'salida_matriz_windows.txt') -Encoding utf8 -Width 180
$captura
