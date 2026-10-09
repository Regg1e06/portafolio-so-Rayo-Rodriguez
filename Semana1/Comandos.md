
# Ayuda memoria de comandos - Semana 1

## Windows - PowerShell

### CPU
`Get-CimInstance Win32_Processor`

Muestra el procesador, sus núcleos, procesadores lógicos y velocidad.

### Memoria RAM
`Get-CimInstance Win32_PhysicalMemory`

Permite consultar la capacidad, velocidad y fabricante de los módulos de memoria.

### Almacenamiento
`Get-PhysicalDisk`

Muestra los discos físicos del equipo.

`Get-Volume`

Muestra las unidades y volúmenes de almacenamiento.

### Buses y dispositivos
`Get-PnpDevice -PresentOnly`

Muestra los dispositivos detectados y presentes en Windows.

### Información general
`systeminfo`

Presenta información del sistema operativo y del equipo.

`msinfo32`

Abre una ventana gráfica con información detallada del sistema.

---

## Linux - Bash

### CPU
`lscpu`

Muestra la arquitectura, los núcleos y los hilos del procesador.

`cat /proc/cpuinfo`

Muestra información detallada de los procesadores lógicos.

### Memoria RAM
`free -h`

Muestra la memoria RAM total, usada, libre y disponible.

`cat /proc/meminfo`

Muestra estadísticas detalladas sobre la memoria.

### Almacenamiento
`lsblk`

Lista los discos y las particiones disponibles.

`df -h`

Muestra el espacio utilizado y disponible en los sistemas de archivos montados.

### Buses y dispositivos
`lspci`

Lista los dispositivos conectados al bus PCI.

`lsusb`

Lista los dispositivos detectados mediante USB.

### Información general
`sudo lshw -short`

Presenta un resumen del hardware detectado por Linux.

---

## Ejercicio adicional: C a ensamblador

`gcc -O0 -S -masm=intel -fno-asynchronous-unwind-tables -fcf-protection=none suma.c`

Genera un archivo ensamblador a partir del código C, sin optimizaciones y utilizando sintaxis Intel.

`cat suma.s`

Muestra el contenido del archivo ensamblador generado.
