# Complemento de los talleres 1 y 2

**Sistemas Operativos GR1 · Miguel Rayo e Italo Rodríguez**

La [hoja de resultados del 11 de noviembre de 2026](Talleres_1_y_2.pdf) contiene las mediciones del taller. Las comprobaciones del verificador y de `jq` que se citan aquí son del 15 de noviembre.

## Taller 1 · Costo y errores de las llamadas al sistema

En el modelo, copiar requiere un `read` y un `write` por bloque, así que para 1 MiB el número de llamadas de transferencia es `2 × ceil(1 048 576 / B)`. El conteo real también puede incluir la lectura que detecta el fin de archivo y llamadas de arranque. Cuando los datos ya están en memoria, basta un `write` por bloque.

| Bloque (bytes) | Ubuntu (ms) | Windows (ms) | Llamadas de transferencia |
| ---: | ---: | ---: | ---: |
| 1 | 1 105 | 5 971,5 | 2 097 152 |
| 16 | 130 | 375,9 | 131 072 |
| 512 | 15 | 14,1 | 4 096 |
| 4 096 | 11 | 3,6 | 512 |
| 65 536 | 10 | 1,3 | 32 |

Ajustamos una recta a los cinco pares `(llamadas, segundos)`. La pendiente estima el costo por llamada y el intercepto recoge el costo fijo de la prueba, que también incluye el arranque y la apertura o cierre de archivos. Si se usa ese intercepto como costo efectivo de mover 1 MiB, el tamaño teórico que deja un 10 % del tiempo en llamadas es `B10 = 9 × 2 × tllamada / tbyte`.

| Sistema | Costo estimado por llamada | B10 estimado | Siguiente potencia de dos |
| --- | ---: | ---: | ---: |
| Ubuntu | 517 ns | 418 B | 512 B |
| Windows | 2 846 ns | 25 098 B | 32 KiB |

En Ubuntu, subir de 4 a 64 KiB ahorró 1 ms. En Windows, con ese mismo cambio el tiempo bajó de 3,6 a 1,3 ms. La medición compara `dd` y `FileStream` en los dos entornos del taller, con su propio arranque, caché y capas de E/S. Los costos estimados corresponden a esas pruebas completas.

### Reto final

Las dos líneas muestran el contenido si la lectura funciona. Si falla, ocultan el error original y muestran `falta notas.txt`.

**Bash**

```bash
cat notas.txt 2>/dev/null || printf '%s\n' 'falta notas.txt'
```

**Windows PowerShell 5.1**

```powershell
Get-Content -LiteralPath .\notas.txt -ErrorAction SilentlyContinue; if (-not $?) { 'falta notas.txt' }
```

`Get-Content` es un cmdlet y su estado se consulta con `$?` inmediatamente después. `$LASTEXITCODE` se usa para el código devuelto por un programa nativo o por un script que llama a `exit`.

## Taller 2 · Tuberías y paquetes

Bash pasa texto por la tubería y `sort -n` interpreta los números. PowerShell pasa objetos y `Sort-Object` puede ordenar directamente valores numéricos como `WS`. Para separar salidas, `>` envía la salida normal a un archivo y `2>` envía los errores a otro.

| Comprobación | Ubuntu | Windows |
| --- | --- | --- |
| Gestor | APT y dpkg | WinGet |
| Versión de jq | Paquete `1.7.1-3ubuntu1.1` | `1.8.2` |
| Fuentes visibles | `plucky-updates/main` y `plucky-security/main` ofrecen la versión instalada según la caché de APT | Origen `winget` y paquete `jqlang.jq` |
| Dependencias | `apt-cache depends jq` mostró `libc6` y `libjq1`. | El registro identifica `jq` como instalación de WinGet. `winget show --id jqlang.jq -e` consulta su ficha. |
| Comprobar integridad | APT valida los metadatos firmados del repositorio y verifica el hash de los paquetes descargados | WinGet compara el SHA-256 del instalador con el manifiesto |
| Desinstalar si se requiere | `sudo apt remove jq` | `winget uninstall --id jqlang.jq -e` |

La ficha de APT identifica los requisitos de `jq`. En el historial local disponible no apareció la transacción de instalación, así que queda sin confirmar cuántos paquetes nuevos se instalaron junto con `jq` en cada sistema.

Prueba de funcionamiento ejecutada en ambos sistemas:

```text
Entrada: {"plato":"sopa","minutos":20}
Filtro:  jq .minutos
Salida:  20
```

La sección C de la hoja registra cómo quedó el trabajo al terminar el taller. En la entrega final se ejecutaron las **seis secciones en ambos sistemas**. Ubuntu dio **3/6 y código 1**. Windows dio **5/5 y código 0** con el PATH actualizado. Los dos informes y los comandos de ejecución están en el [README de la semana](../README.md).

