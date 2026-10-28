# Ayuda memoria de la semana 3

| Consulta | Ubuntu / Linux | Windows / PowerShell |
|---|---|---|
| Primer proceso | `ps -p 1 -o pid,comm` | `Get-Process -Id 4` |
| Total de procesos | `ps -e --no-headers \| wc -l` | `(Get-Process).Count` |
| CPU disponible | `nproc` | `(Get-CimInstance Win32_Processor).NumberOfLogicalProcessors` |
| Servicios | `systemctl list-units --type=service --state=running` | `Get-Service \| Where-Object Status -eq Running` |
| RAM | `free -h` | `Get-CimInstance Win32_OperatingSystem \| Select-Object TotalVisibleMemorySize,FreePhysicalMemory` |
| Discos | `lsblk` | `Get-CimInstance Win32_LogicalDisk` |
| CPU ociosa | `vmstat 1 2` (segunda muestra, id y wa) | `Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor -Filter "Name='_Total'"` |
| Último arranque | `uptime -s` | `(Get-CimInstance Win32_OperatingSystem).LastBootUpTime` |
| Desglose | `systemd-analyze time` | `FwPOSTTime` y evento 100 |
| Unidades lentas | `systemd-analyze blame` y `critical-chain` | Servicios automáticos detenidos; evento 101 opcional |
| Módulos / drivers | `lsmod`, `modinfo dummy` | `driverquery`, `Get-CimInstance Win32_SystemDriver` |
| Estado final | `systemctl get-default`, `systemctl --failed` | `HiberbootEnabled`, `powercfg /a` |

`p = 1 âˆ’ (user + sys)/real`. En Windows, CPU suma tiempo de usuario y privilegiado.
En el modelo de la guía, `U = 1 − p^n`; para `0 < p < 1`, `n = ceil(log(0.1)/log(p))` permite estimar U ≥ 90 %.
Es un modelo de multiprogramación: la medida puede incluir espera de planificación y sobrecarga, y la RAM limita cuántos procesos caben.

`blame` muestra duración de activación: las unidades pueden iniciarse en paralelo. Hay que revisar `critical-chain` para identificar la ruta que retrasa el arranque.
