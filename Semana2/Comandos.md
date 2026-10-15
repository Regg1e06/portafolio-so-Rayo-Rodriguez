# Ayuda memoria de comandos - Semana 2

## Reporte de memoria en Windows

| Comando PowerShell | Para qué sirve |
| --- | --- |
| `$env:COMPUTERNAME` | Nombre del equipo |
| `Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'` | Fecha, hora y zona |
| `Get-CimInstance Win32_OperatingSystem` | Sistema operativo y memoria visible |
| `$env:PROCESSOR_ARCHITECTURE` | Arquitectura del proceso; si es de 32 bits en Windows de 64 bits, consultar también `PROCESSOR_ARCHITEW6432` |
| `[BitConverter]::IsLittleEndian` | `True` indica little-endian |
| `Get-CimInstance Win32_CacheMemory` | Información de caché reportada por CIM |
| `Get-CimInstance Win32_Processor \| Select-Object L2CacheSize,L3CacheSize` | Capacidades de L2 y L3 reportadas en KiB |
| `Get-CimInstance Win32_OperatingSystem \| Select-Object TotalVisibleMemorySize,FreePhysicalMemory` | RAM total visible y libre, en KiB |
| `Get-CimInstance Win32_PageFileUsage` | Tamaño asignado y uso de paginación, en MiB |
| `Get-PhysicalDisk \| Select-Object FriendlyName,MediaType,Size` | Nombre, tipo y tamaño en bytes de los discos |
| `Format-Hex -Path .\t.txt` | Volcado de bytes de un archivo |
| `Out-File -Encoding utf8` | Guardar texto con UTF-8; PowerShell 5.1 añade BOM |

`Win32_CacheMemory.Associativity` es una enumeración: por ejemplo, el código 7 representa 8 vías. `Level` también es una enumeración, no el número de nivel escrito directamente. El script usa la API nativa de Windows para obtener L1d/L1i, capacidad, línea y vías por instancia.

### Demo de texto sin depender de PowerShell 7

```powershell
# UTF-8 sin BOM y terminación CR LF; funciona en PowerShell 5.1 y 7.
$utf8 = New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $PWD 't.txt'), "Año`r`n", $utf8)
Format-Hex -Path .\t.txt
# Bytes: 41 C3 B1 6F 0D 0A
```

En PowerShell 7 también sirve `'Año' | Set-Content t.txt -Encoding utf8NoBOM`. Ese nombre de codificación no existe en Windows PowerShell 5.1.

## Reporte de memoria en Linux o WSL

| Comando Bash | Para qué sirve |
| --- | --- |
| `hostname` | Nombre del equipo |
| `date --iso-8601=seconds` | Fecha y hora con zona |
| `cat /etc/os-release` | Distribución instalada |
| `uname -sr` | Nombre y versión del kernel |
| `uname -m` | Arquitectura, por ejemplo `x86_64` o `aarch64` |
| `LC_ALL=C lscpu \| grep 'Byte Order'` | Orden de bytes con etiquetas en inglés |
| `lscpu --caches` | Geometría de cachés; distinguir ONE-SIZE de ALL-SIZE |
| `lscpu -B --caches` | Capacidades en bytes en versiones compatibles |
| `getconf LEVEL1_DCACHE_LINESIZE` | Tamaño de línea L1d en bytes |
| `cat /sys/devices/system/cpu/cpu0/cache/index0/size` | Capacidad de una instancia; comprobar `level` y `type`, porque index0 no tiene por qué ser L1d en todos los equipos |
| `free -h` | RAM y swap con unidades legibles |
| `free -b` | RAM y swap en bytes |
| `lsblk -d -o NAME,ROTA,SIZE` | Discos y si son rotacionales |
| `lsblk -d -b -o NAME,TYPE,ROTA,SIZE,MODEL` | Más detalle, tamaño en bytes |
| `tee salida.txt` | Mostrar y guardar la misma salida |
| `bash ejecutar_todo.sh` | Ejecutar el reporte y las demos de una vez |

En Linux `MemFree` es memoria completamente libre; `MemAvailable` estima cuánto se puede usar sin recurrir a swap. No son lo mismo. Una VM puede ocultar información física.

## Comandos usados en las demos de clase

Ejecutar desde `Semana2/clases` en Linux/WSL:

```bash
# Modelo de programación: convertir C a ensamblador en x86-64.
mkdir -p generados
gcc -S -O0 -masm=intel suma.c -o generados/suma_O0.s
cat generados/suma_O0.s

# Datos y volcados: el script prepara t.txt, n.bin y datos.bin.
python3 datos.py generados
xxd generados/t.txt
xxd generados/n.bin
xxd generados/datos.bin

# Localidad espacial: mismo programa, dos recorridos.
gcc -std=c11 -Wall -Wextra -O0 matriz.c -o generados/matriz
./generados/matriz
./generados/matriz c
```

En ARM64 se omite `-masm=intel`. El ejecutor `demo_clase.sh` lo decide automáticamente. Los registros de argumentos dependen del sistema: en Linux x86-64 suelen usarse EDI y ESI para esta función; Windows x64 utiliza ECX y EDX.

Para guardar de una vez la salida de las demos:

```bash
bash demo_clase.sh
```

Desde `Semana2`, en Windows:

```powershell
.\clases\demo_clase.ps1
.\clases\demo_matriz.ps1
```

## Fórmulas

| Cálculo | Expresión | Cuidado |
| --- | --- | --- |
| Conjuntos de caché | `S = C / (L*A)` | C por instancia y L en bytes |
| Desplazamiento | `log2(L)` bits | L potencia de dos |
| Índice | `log2(S)` bits | S potencia de dos |
| Etiqueta | `bits_dirección - índice - desplazamiento` | Los ejemplos de clase usan 32 bits |
| Tasa de aciertos | `h = aciertos / accesos` | Para calcular, usar 0 a 1 |
| Tiempo medio | `Tc + (1-h)*Tm` | Sumar Tc incluso si hay fallo |
| Rango con signo | `-2^(n-1)` a `2^(n-1)-1` | Complemento a 2 |
| Rango sin signo | `0` a `2^n-1` | CF detecta acarreo |

KiB = 1024 bytes; MiB = 1024² bytes; GiB = 1024³ bytes.
