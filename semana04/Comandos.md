# Ayuda memoria de comandos de la Semana 4

**Sistemas Operativos GR1 · Miguel Rayo e Italo Rodríguez**

## Taller 1 · Llamadas al sistema

| Tarea | Linux (Bash) | Windows (PowerShell) |
| --- | --- | --- |
| Contar llamadas de un programa | `strace -c ls > /dev/null` | Process Monitor permite observar eventos de procesos y archivos. Su uso puede requerir administrador. |
| Ver llamadas de apertura, lectura, escritura y cierre | `strace -e trace=openat,read,write,close cat notas.txt` | Equivalentes de Win32: `CreateFile`, `ReadFile`, `WriteFile` y `CloseHandle`. |
| Consultar bibliotecas o módulos | `ldd /bin/ls` | `(Get-Process -Id $PID).Modules \| Select-Object -First 8 ModuleName, FileName` |
| Identificar la terminal | `tty` y `ps -o comm= -p "$PPID"` | `Get-Process conhost, WindowsTerminal -ErrorAction SilentlyContinue` |
| Ocultar los errores de lectura | `cat notas.txt 2>/dev/null` | `Get-Content -LiteralPath .\notas.txt -ErrorAction SilentlyContinue` |
| Consultar el estado de la última orden | `echo "$?"` | `$?` para el último comando y `$LASTEXITCODE` para el código de un ejecutable nativo o un script que termina con `exit`. |

**Medir la copia de 1 MiB en Bash**

~~~bash
head -c 1048576 /dev/urandom > datos.bin
for B in 1 16 512 4096 65536; do
    printf '\nBloque de %s bytes\n' "$B"
    time dd if=datos.bin of=copia.bin bs="$B" status=none
done
~~~

En Windows, el taller mide esos mismos tamaños con `Stopwatch` y `FileStream` de .NET. El búfer interno se configura con tamaño `1` para observar mejor el costo de leer y escribir cada bloque. Se usa `strace` para contar llamadas y `time` o `Stopwatch` para medir la ejecución sin trazas.

## Taller 2 · Tuberías y redirecciones

| Tarea | Linux (Bash) | Windows (PowerShell) |
| --- | --- | --- |
| Ver los tres procesos con más memoria residente | `ps -eo comm,pid,rss --no-headers \| sort -k3,3nr \| head -n 3` | `Get-Process \| Sort-Object WS -Descending \| Select-Object -First 3 Name,Id,WS` |
| Ordenar números de menor a mayor | `printf '%s\n' 999 1000 25 \| sort -n` | `999, 1000, 25 \| Sort-Object` |
| Guardar datos y errores por separado | `ls /etc /noexiste > salida.txt 2> errores.txt` | `Get-ChildItem C:\Windows,C:\NoExiste > salida.txt 2> errores.txt` |
| Examinar lo que pasa por la tubería | `ps -eo comm,pid,rss \| head -n 4` muestra líneas de texto. | `Get-Process \| Get-Member -MemberType Property` muestra las propiedades de los objetos. |

## Taller 2 · Gestores de paquetes

| Tarea | Ubuntu | AlmaLinux | Windows |
| --- | --- | --- | --- |
| Ver orígenes | `apt-cache policy` | `dnf repolist` | `winget source list` |
| Buscar y consultar `jq` | `apt search jq` y `apt show jq` | `dnf search jq` y `dnf info jq` | `winget search jq` y `winget show --id jqlang.jq -e` |
| Consultar dependencias | `apt-cache depends jq` | `dnf repoquery --requires jq` | `winget show --id jqlang.jq -e` |
| Instalar si hace falta | `sudo apt install jq` | `sudo dnf install jq` | `winget install --id jqlang.jq -e` |
| Consultar versión instalada | `dpkg-query -W jq` | `rpm -q jq` | `winget list --id jqlang.jq -e` |
| Consultar historial | `tail -n 20 /var/log/apt/history.log` | `dnf history list` | Consultar `InstallDate` en las claves `Uninstall` del registro. |

**Probar jq** · En Bash o PowerShell, `'{"plato":"sopa","minutos":20}'` es el texto de entrada.

~~~bash
printf '%s\n' '{"plato":"sopa","minutos":20}' | jq .minutos
~~~

~~~powershell
'{"plato":"sopa","minutos":20}' | jq .minutos
~~~

La salida esperada es `20`.

## Deber 4 · Verificadores

Desde la carpeta `semana04/`, ejecutar `bash ./verificador_entorno.sh` en Linux o `.\verificador_entorno.ps1` en PowerShell. Los scripts generan un informe TXT y devuelven `0` si todas las herramientas están disponibles o `1` si falta alguna o el informe no puede guardarse. Los verificadores muestran los comandos de instalación cuando hacen falta.

