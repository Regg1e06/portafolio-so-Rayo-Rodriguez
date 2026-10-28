# Semana 3 - Sistemas Operativos

**Tema:** Introducción al SO, procesos, servicios, arranque y controladores.  
**Integrantes:** Miguel Rayo, Italo Rodriguez.  
**Docente:** Rubén Rumipamba. **Paralelo:** GR1.

## Contenido

El Deber 3 reúne dos scripts de informe de arranque con las seis secciones de la guía. Los talleres añaden consultas de procesos, memoria, servicios, CPU ociosa y mediciones de espera.
Se usa `semana03/` porque es el nombre pedido en el enunciado y en la rúbrica; las semanas anteriores conservan `Semana1/` y `Semana2/`.

| Archivo | Uso |
|---|---|
| [informe_arranque.ps1](informe_arranque.ps1) | Deber 3 en Windows |
| [informe_arranque.sh](informe_arranque.sh) | Deber 3 en Linux |
| [ejecutar_todo.ps1](ejecutar_todo.ps1) | Informe y talleres de Windows |
| [ejecutar_todo.sh](ejecutar_todo.sh) | Informe y talleres de Ubuntu en una ejecución |
| [talleres_windows.ps1](talleres_windows.ps1) | Consultas y tres mediciones de Windows |
| [talleres_linux.sh](talleres_linux.sh) | Consultas y tres mediciones de Linux |
| [clases/carga_cpu.ps1](clases/carga_cpu.ps1) | Programa de cálculo para la medición |
| [Comandos.md](Comandos.md) | Ayuda memoria y fórmulas |
| [Practicas_manuales.md](Practicas_manuales.md) | Pasos interactivos de módulos, teclado y reinicio programado |
| [reportes/windows/](reportes/windows/) | Salidas reales de Windows |
| [reportes/linux/](reportes/linux/) | Salidas reales de Ubuntu en VMware |

## Secciones del informe

1. SO, versión y núcleo o compilación.
2. Último arranque y tiempo encendido.
3. Desglose del arranque; aviso si falta un comando, permiso o registro.
4. Cinco unidades más lentas en Linux; servicios activos y automáticos detenidos en Windows.
5. Total de módulos y cinco más grandes en Linux; driverquery y controladores activos en Windows.
6. Target y unidades fallidas en Linux; estado del inicio rápido en Windows.

## Ejecutar en Windows

Abrir PowerShell dentro de esta carpeta y ejecutar sin administrador:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\ejecutar_todo.ps1
```

Para solo el deber: `powershell -NoProfile -ExecutionPolicy Bypass -File .\informe_arranque.ps1`.
Bypass se aplica a ese proceso. No cambia de forma permanente la política del equipo.

## Ejecutar todo en Ubuntu

Copiar la carpeta `semana03` a Ubuntu, abrir una terminal dentro de ella y ejecutar:

```bash
bash ejecutar_todo.sh
```

No requiere sudo ni pregunta datos; guarda los informes de ambos scripts en `reportes/linux/` con equipo y fecha/hora. En una VM con Ubuntu y systemd se obtienen los datos de esa VM.
Si falta alguna herramienta, instalar previamente en Ubuntu:

```bash
sudo apt update
sudo apt install procps psmisc util-linux kmod iproute2
```

Para solo el deber: `bash informe_arranque.sh`. El ejecutor usa `sleep 2` como espera automática; el `read` de la guía se hace aparte en una terminal.
La guía usa AlmaLinux; aquí se adapta la ejecución a Ubuntu por usarlo en casa. No se utiliza el preparador de AlmaLinux en Ubuntu.

## Estado y límites de la evidencia

- Windows: ver el archivo [ESTADO.md](ESTADO.md), que registra la ejecución realizada y los avisos observados.
- Ubuntu: ejecutado por el estudiante en VMware; seis secciones revisadas y salidas incorporadas. Ver [Resultados_Ubuntu.md](Resultados_Ubuntu.md).
- Evento 100: sin administrador se registra un aviso, como permite la guía. La fecha del último evento puede diferir del arranque actual.
- Módulos y reinicio programado: prácticas manuales pendientes; los ejecutores solo consultan el sistema.
- Bases originales: completadas conservando funciones y títulos del docente. Ver [Analisis_muestras.md](Analisis_muestras.md) para la máquina B. La ejecución del simulador sigue pendiente.

## Entrega y participación

Subir los dos scripts del deber y al menos un `.txt` real de cada sistema. Revisar los avisos; si falta un dato por permisos, conservar la explicación.
Cada integrante debe hacer un commit con su aporte desde su propia cuenta. El historial debe reflejar contribuciones reales; copiar archivos no crea esos commits.

## Uso de IA

Se utilizó ChatGPT/Codex para explicar comandos, generar y depurar scripts, organizar los README y revisar las salidas. La declaración también figura en las cabeceras de los scripts. Las salidas corresponden a ejecuciones reales cuando así se indica; los resultados pendientes se identifican expresamente.
