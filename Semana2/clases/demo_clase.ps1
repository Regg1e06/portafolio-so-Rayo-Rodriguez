# Reproduce la demo Format-Hex de la semana 2. PowerShell 5.1 y 7.
# Se usa .NET para UTF-8 sin BOM; utf8NoBOM no esta en Windows PowerShell 5.1.
[CmdletBinding()]
param([string]$DirectorioSalida = (Join-Path (Split-Path $PSScriptRoot -Parent) 'reportes/windows'))
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $DirectorioSalida | Out-Null
$generados = Join-Path $PSScriptRoot 'generados'
New-Item -ItemType Directory -Force -Path $generados | Out-Null
$salida = & {
    'DEMO DE CLASE - WINDOWS'
    "Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
    '== Texto UTF-8 sin BOM y con CR LF =='
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [IO.File]::WriteAllText((Join-Path $generados 't.txt'), "A$([char]0xF1)o`r`n", $utf8)
    Format-Hex -InputObject ([IO.File]::ReadAllBytes((Join-Path $generados 't.txt'))) | Out-String -Width 160
    '== Entero -100, 32 bits, little-endian =='
    $bytes = [BitConverter]::GetBytes([int]-100)
    if (-not [BitConverter]::IsLittleEndian) { [Array]::Reverse($bytes) }
    [IO.File]::WriteAllBytes((Join-Path $generados 'n.bin'), $bytes)
    Format-Hex -InputObject ([IO.File]::ReadAllBytes((Join-Path $generados 'n.bin'))) | Out-String -Width 160
    '== 0xCAFEBABE en memoria =='
    $valor = [Convert]::ToUInt32('CAFEBABE',16)
    $little = [BitConverter]::GetBytes($valor)
    if (-not [BitConverter]::IsLittleEndian) { [Array]::Reverse($little) }
    'Little-endian: ' + (($little | ForEach-Object { '{0:X2}' -f $_ }) -join ' ')
    [Array]::Reverse($little)
    'Big-endian:    ' + (($little | ForEach-Object { '{0:X2}' -f $_ }) -join ' ')
    'La interpretacion depende del ancho, signo y orden de bytes.'
}
$salida | Out-File -LiteralPath (Join-Path $DirectorioSalida 'salida_clase_windows.txt') -Encoding utf8 -Width 180
$salida
