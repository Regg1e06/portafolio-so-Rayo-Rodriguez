# Semana 2 - Sistemas Operativos

**Tema:** Modelo de programación, memoria y representación de datos.  
**Integrantes:** Miguel Rayo, Italo Rodriguez.  
**Docente:** Rubén Rumipamba.

## Descripción

En esta semana se trabajaron registros, ISA, modos usuario y núcleo, pila, representación de datos y jerarquía de memoria. El Deber 2 aplica estos temas mediante dos scripts equivalentes que consultan la memoria del equipo en Windows y Linux.

La carpeta se llama `Semana2` para mantener el formato `Semana1` del repositorio y la organización semanal indicada en Moodle. Corresponde a la carpeta `semana02/` mencionada en la guía de laboratorio.

## Archivos

| Archivo o carpeta | Contenido |
| --- | --- |
| [Comandos.md](Comandos.md) | Ayuda memoria de comandos Windows y Linux |
| [Apuntes.md](Apuntes.md) | Modelo de programación, datos, memoria y fórmulas |
| [memoria.ps1](memoria.ps1) | Reporte de memoria en Windows |
| [memoria.sh](memoria.sh) | Reporte de memoria en Linux o WSL |
| [ejecutar_todo.ps1](ejecutar_todo.ps1) | Reporte y demos de Windows en una ejecución |
| [ejecutar_todo.sh](ejecutar_todo.sh) | Reporte y demos de Linux en una ejecución |
| [clases/](clases/) | Código de matriz, suma y demos de datos de la semana |
| [Laboratorio.md](Laboratorio.md) | Resultados del modelo de caché y explicación de los ejercicios |
| [reportes/windows/](reportes/windows/) | Salidas reales generadas en Windows |
| [reportes/linux/](reportes/linux/) | Lugar de las salidas que se generarán al ejecutar en Linux |

## Requisitos

Windows: PowerShell 5.1 o 7. El reporte y la demo hexadecimal no necesitan instalar paquetes ni ejecutar como administrador. La demo opcional de la matriz necesita GCC en `PATH`, por ejemplo el de MSYS2 UCRT64.

Linux/WSL: Bash 4 o posterior, `lscpu`, `lsblk`, `free` y `getconf` para el reporte; GCC, Python 3 y `xxd` para las demos. En Ubuntu, si falta alguno, se puede instalar con:

```bash
sudo apt update
sudo apt install build-essential python3 xxd util-linux procps libc-bin
```

La instalación es un paso previo opcional. Los scripts de consulta se ejecutan sin `sudo`.

## Ejecutar todo en Windows

Abre una terminal dentro de `Semana2` y ejecuta:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\ejecutar_todo.ps1
```

`Bypass` se aplica únicamente a ese proceso. El script guarda:

- `reportes/windows/memoria_<equipo>.txt`
- `reportes/windows/salida_clase_windows.txt`
- `reportes/windows/salida_matriz_windows.txt`, si GCC está disponible
- `reportes/windows/salida_todo_windows.txt`

Para ejecutar solo el deber de memoria:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\memoria.ps1
```

## Ejecutar todo en Linux o WSL

Desde la carpeta `Semana2`, basta un comando:

```bash
bash ejecutar_todo.sh
```

En WSL, si los archivos siguen en el Escritorio de Windows:

```bash
cd /mnt/c/Users/USUARIO/Desktop/deb2SISOP/Para_GitHub/Semana2
bash ejecutar_todo.sh
```

Se guardan `reportes/linux/memoria_<equipo>.txt`, `salida_clase_linux.txt` y `salida_todo_linux.txt`. La captura completa queda en este último archivo: no hace falta copiar comandos uno por uno. Las demos avisan si faltan dependencias.

Para ejecutar solamente el reporte:

```bash
bash memoria.sh
```

## Información del reporte

Los dos scripts incluyen equipo, SO y fecha; arquitectura y orden de bytes; cachés L1d, L1i, L2 y L3; conjuntos de L1d; RAM total y libre; swap o archivo de paginación; nombre, tipo y tamaño de los discos.

Para L1d se usa **S = C / (L × A)**, con C y L en bytes. Se calcula por instancia de caché, sin sumar las capacidades de todos los núcleos. En Windows se consulta también `GetLogicalProcessorInformationEx`, porque CIM puede agrupar las cachés y no exponer el tamaño de línea. En Linux se leen las instancias de sysfs sin duplicar las cachés compartidas entre CPU.

Si el SO o la máquina virtual no expone un campo, se informa como no disponible. En WSL, el disco y la RAM visibles pueden ser los del entorno virtual; el indicador de rotación no prueba el tipo físico del disco anfitrión.

### Ejemplo de salida real de Windows

```text
Arquitectura: x86_64
Orden de bytes: little-endian
L1d (datos): C=32768 bytes (32.00 KiB); A=8; L=64 bytes; instancias=6
  S = C/(L*A) = 32768/(64*8) = 64 conjuntos por instancia.
```

El reporte completo está en [reportes/windows/](reportes/windows/). La RAM libre y el uso de paginación cambian entre ejecuciones.

## Demos de clase

- [demo_clase.ps1](clases/demo_clase.ps1): UTF-8, `Format-Hex`, entero −100 y endianness.
- [demo_clase.sh](clases/demo_clase.sh): ejecuta datos, volcados, ensamblador y matriz en Linux.
- [datos.py](clases/datos.py): reto hexadecimal, banderas de 8 y 16 bits, UTF-8 e IEEE 754. Las banderas son una simulación aritmética.
- [suma.c](clases/suma.c): función de las diapositivas para observar pila y ensamblador con `-O0`.
- [matriz.c](clases/matriz.c): adaptación del código entregado en `scriptMatrizRecorrido.txt`; compara filas y columnas.
- [demo_matriz.ps1](clases/demo_matriz.ps1): compila la matriz y guarda los tiempos de Windows.

En la matriz se cambió el acumulador de `long` a `int64_t`: en Windows `long` suele ser de 32 bits y la suma esperada, **68 702 699 520**, no cabe. Ambos recorridos deben producir esa suma. Los ejecutables y binarios temporales quedan en `clases/generados/`, excluidos con `.gitignore`.

## Estado de las evidencias

| Evidencia | Estado |
| --- | --- |
| Reporte de memoria Windows | Ejecutado; salida real incluida |
| Demo hexadecimal Windows | Ejecutada; salida real incluida |
| Matriz en Windows | Compilada con GCC y ejecutada; salida real incluida |
| Script de memoria y demos Linux | Código preparado y sintaxis Bash revisada; falta ejecución en Linux/WSL |
| Experimentos de caché | Reproducidos con las funciones del HTML docente; identificados como simulación en Laboratorio.md |

**Pendiente antes de entregar:** ejecutar `bash ejecutar_todo.sh` en Linux/WSL y subir los `.txt` generados. El aviso `reportes/linux/PENDIENTE_LINUX.txt` no es una captura de ejecución y se puede borrar después de generar las salidas reales. Si faltan dependencias o campos que el SO no exponga, revisar los avisos de la captura.

La rúbrica exige aportes de ambos integrantes en el historial: cada integrante debe realizar sus propios commits. El Word con el enlace se entrega en Moodle.

## Uso de IA generativa

Se utilizó ChatGPT/Codex para organizar los archivos, explicar comandos y fórmulas, apoyar la escritura y depuración de los scripts y verificar las salidas disponibles de Windows y el modelo del simulador. La ejecución en Linux permanece pendiente y no se presenta como realizada.

## Material de referencia

- `Guia_Laboratorio_Semana02_v4.docx`: objetivos, experimentos y anexo A del deber.
- `SO_Semana02_ModeloProgramacion_Memoria_Datos_v3.pdf`: temas 1.4 a 1.6 y demos.
- `SO_HiloNarrativo_Asignatura_v3.pdf`: relación de la semana con el resto de la asignatura.
- `Laboratorio_Memoria_Cache.html` y `scriptMatrizRecorrido.txt`: recursos entregados para clase.
- [Microsoft Learn: CACHE_RELATIONSHIP](https://learn.microsoft.com/en-us/windows/win32/api/winnt/ns-winnt-cache_relationship): campos nativos de caché de Windows.
- [Microsoft Learn: Win32_CacheMemory](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-cachememory): unidades y códigos de la consulta CIM.
