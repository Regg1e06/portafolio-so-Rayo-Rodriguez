# Deber 2 - Sistemas Operativos - Miguel Rayo e Italo Rodriguez
# Reporte de solo lectura. PowerShell 5.1 o 7 en Windows; no requiere administrador.
# Ejemplo: powershell -NoProfile -ExecutionPolicy Bypass -File .\memoria.ps1
[CmdletBinding()]
param([string]$DirectorioSalida = (Join-Path $PSScriptRoot 'reportes/windows'))
$ErrorActionPreference = 'Stop'
New-Item -ItemType Directory -Force -Path $DirectorioSalida | Out-Null
$equipo = $env:COMPUTERNAME -replace '[^a-zA-Z0-9_.-]', '_'
$ruta = Join-Path $DirectorioSalida "memoria_$equipo.txt"

function GiB($bytes) { '{0:N2} GiB ({1} bytes)' -f ($bytes / 1GB), $bytes }

# Win32_CacheMemory no siempre informa linea y vias. La API de Windows entrega
# un registro por cache real, incluso si varios nucleos la comparten.
# Los offsets son los campos iniciales de CACHE_RELATIONSHIP (Microsoft Learn).
function Leer-Caches {
    if (-not ('Semana2.CacheWindows' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.InteropServices;
namespace Semana2 {
  public class CacheDato {
    public byte Nivel, Vias;
    public ushort Linea;
    public uint Bytes;
    public int Tipo;
  }
  public static class CacheWindows {
    [DllImport("kernel32.dll", SetLastError=true)]
    static extern bool GetLogicalProcessorInformationEx(int relacion, IntPtr datos, ref uint longitud);
    public static CacheDato[] Leer() {
      uint longitud = 0;
      GetLogicalProcessorInformationEx(2, IntPtr.Zero, ref longitud); // RelationCache
      if (longitud == 0) throw new Win32Exception(Marshal.GetLastWin32Error());
      IntPtr buffer = Marshal.AllocHGlobal(checked((int)longitud));
      try {
        if (!GetLogicalProcessorInformationEx(2, buffer, ref longitud))
          throw new Win32Exception(Marshal.GetLastWin32Error());
        var salida = new List<CacheDato>();
        int offset = 0;
        while (offset <= (int)longitud - 8) {
          IntPtr p = IntPtr.Add(buffer, offset);
          int relacion = Marshal.ReadInt32(p, 0), tam = Marshal.ReadInt32(p, 4);
          if (tam < 20 || tam > (int)longitud - offset) throw new Exception("Registro de cache invalido");
          if (relacion == 2) salida.Add(new CacheDato {
            Nivel = Marshal.ReadByte(p, 8), Vias = Marshal.ReadByte(p, 9),
            Linea = (ushort)Marshal.ReadInt16(p, 10), Bytes = (uint)Marshal.ReadInt32(p, 12),
            Tipo = Marshal.ReadInt32(p, 16)
          });
          offset += tam;
        }
        return salida.ToArray();
      } finally { Marshal.FreeHGlobal(buffer); }
    }
  }
}
'@
    }
    [Semana2.CacheWindows]::Leer()
}

$reporte = & {
    'DEBER 2 - REPORTE DE MEMORIA - WINDOWS'
    '== 1. Equipo, sistema y fecha =='
    "Equipo: $env:COMPUTERNAME"
    "Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
    try {
        $so = Get-CimInstance Win32_OperatingSystem
        "SO: $($so.Caption) | Version: $($so.Version) | $($so.OSArchitecture)"
    } catch { "SO: no disponible ($($_.Exception.Message))" }
    "PowerShell: $($PSVersionTable.PSVersion)"
    '== 2. Arquitectura y orden de bytes =='
    $arquitectura = if ($env:PROCESSOR_ARCHITEW6432) { $env:PROCESSOR_ARCHITEW6432 } else { $env:PROCESSOR_ARCHITECTURE }
    switch ($arquitectura) { 'AMD64' { $arquitectura = 'x86_64' }; 'ARM64' { $arquitectura = 'ARM64' } }
    "Arquitectura: $arquitectura"
    "Orden de bytes: $(if ([BitConverter]::IsLittleEndian) {'little-endian'} else {'big-endian'})"

    '== 3. Caches y conjuntos de L1d =='
    'Fuente: GetLogicalProcessorInformationEx(RelationCache). Capacidad POR instancia.'
    'Se agrupan instancias de geometria identica; no se usa la suma para calcular S.'
    try {
        $caches = @(Leer-Caches)
        if ($caches.Count -eq 0) { 'No disponible: Windows no devolvio registros de cache.' }
        foreach ($grupo in ($caches | Group-Object Nivel,Tipo,Bytes,Vias,Linea)) {
            $c = $grupo.Group[0]
            $tipo = switch ($c.Tipo) { 0 {'unificada'}; 1 {'instrucciones'}; 2 {'datos'}; default {'otro'} }
            $nombre = if ($c.Nivel -eq 1 -and $c.Tipo -eq 2) {'L1d'} elseif ($c.Nivel -eq 1 -and $c.Tipo -eq 1) {'L1i'} else {"L$($c.Nivel)"}
            $vias = if ($c.Vias -eq 255) {'totalmente asociativa'} elseif ($c.Vias -gt 0) {"$($c.Vias)"} else {'no disponible'}
            "{0} ({1}): C={2} bytes ({3:N2} KiB); A={4}; L={5} bytes; instancias={6}" -f $nombre,$tipo,$c.Bytes,($c.Bytes/1KB),$vias,$c.Linea,$grupo.Count
            if ($c.Nivel -eq 1 -and ($c.Tipo -eq 2 -or $c.Tipo -eq 0)) {
                if ($c.Linea -gt 0 -and $c.Vias -eq 255) { '  S = 1 conjunto (totalmente asociativa).' }
                elseif ($c.Linea -gt 0 -and $c.Vias -gt 0 -and $c.Bytes -gt 0) {
                    $denominador = [double]$c.Linea * $c.Vias
                    '  S = C/(L*A) = {0}/({1}*{2}) = {3} conjuntos por instancia.' -f $c.Bytes,$c.Linea,$c.Vias,($c.Bytes/$denominador)
                } else { '  S: no calculable; faltan C, L o A.' }
            }
        }
        foreach ($nivel in 1,2,3) {
            if (-not ($caches | Where-Object Nivel -eq $nivel)) { "L${nivel}: no reportada por el SO." }
        }
    } catch {
        "API de cache no disponible: $($_.Exception.Message)"
        'S de L1d: no calculable sin capacidad, vias y linea verificables.'
    }
    'Consulta de clase: Get-CimInstance Win32_CacheMemory (InstalledSize en KiB)'
    try {
        Get-CimInstance Win32_CacheMemory | Select-Object Purpose,Level,InstalledSize,Associativity |
            Format-Table -AutoSize | Out-String -Width 180
        'Associativity en CIM es un codigo enumerado; no equivale directamente a numero de vias.'
        Get-CimInstance Win32_Processor | Select-Object L2CacheSize,L3CacheSize |
            Format-Table -AutoSize | Out-String -Width 180
    } catch { "CIM de cache: no disponible ($($_.Exception.Message))" }

    '== 4. RAM =='
    try {
        $so = Get-CimInstance Win32_OperatingSystem
        "RAM total visible para el SO: $(GiB ([uint64]$so.TotalVisibleMemorySize * 1KB))"
        "RAM libre reportada por Windows: $(GiB ([uint64]$so.FreePhysicalMemory * 1KB))"
    } catch { "RAM: no disponible ($($_.Exception.Message))" }
    '== 5. Archivo de paginacion =='
    try {
        $paginas = @(Get-CimInstance Win32_PageFileUsage)
        if ($paginas.Count -eq 0) { 'Windows no reporta archivos de paginacion activos.' }
        $i = 0
        foreach ($p in $paginas) {
            $i++
            "Archivo ${i}: asignado=$($p.AllocatedBaseSize) MiB; uso actual=$($p.CurrentUsage) MiB; pico=$($p.PeakUsage) MiB"
        }
    } catch { "Paginacion: no disponible ($($_.Exception.Message))" }
    '== 6. Discos =='
    try {
        $discos = @(Get-PhysicalDisk)
        foreach ($d in $discos) {
            $tipo = if ("$($d.MediaType)" -in @('SSD','HDD')) { "$($d.MediaType)" } else { 'no determinado por el SO' }
            "Nombre: $($d.FriendlyName) | Tipo: $tipo | Tamano: $(GiB $d.Size)"
        }
        if ($discos.Count -eq 0) { 'No se reportaron discos fisicos.' }
    } catch {
        'Get-PhysicalDisk no disponible. Alternativa Win32_DiskDrive:'
        try { Get-CimInstance Win32_DiskDrive | ForEach-Object { "Nombre: $($_.Model) | Tipo: no determinado | Tamano: $(GiB $_.Size)" } }
        catch { "Discos: no disponible ($($_.Exception.Message))" }
    }
    '== Fin =='
    'Lectura real del SO; no se incluyen numeros de serie, usuarios ni direcciones de red.'
}
$reporte | Out-File -LiteralPath $ruta -Encoding utf8 -Width 200
$reporte
"Reporte guardado: reportes/windows/$([IO.Path]::GetFileName($ruta))"
