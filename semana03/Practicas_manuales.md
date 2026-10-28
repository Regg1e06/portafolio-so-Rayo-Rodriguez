# Prácticas que requieren intervención

Estos pasos pertenecen a los talleres. El Deber 3 exige informes de consulta y no necesita ejecutar estos cambios.
Las salidas de estas prácticas siguen pendientes hasta realizarlas en el equipo propio.

## Espera por teclado en Ubuntu

Ejecutar en una terminal interactiva; guardar manualmente los tiempos impresos:

```bash
time read -r -p "Escribe tu nombre: " nombre
```

El ejecutor automático usa `sleep 2` como demostración adicional de espera, identificado en la salida.

## Módulo dummy en Ubuntu

Primero revisar si ya existe: `lsmod | grep '^dummy '`. Si ya está cargado, no retirarlo: puede estar en uso.
Si no estaba cargado y se está usando una VM propia para la práctica:

```bash
ip -brief link
modinfo dummy | head -n 4
sudo modprobe dummy
lsmod | grep '^dummy '
ip -brief link
sudo rmmod dummy
ip -brief link
```

Anotar si apareció y desapareció `dummy0`; no afirmar que ocurrió sin verlo. Si el módulo está en uso, detener la práctica y revisar qué lo utiliza.

## Programar y cancelar en el equipo propio

Ejecutar cada par junto, con la terminal abierta. Verificar que la cancelación tuvo éxito; si falla, repetir inmediatamente la cancelación. No hacerlo en un equipo compartido de laboratorio.

Ubuntu:

```bash
sudo shutdown -r +5 "Prueba del taller: no se reiniciará"
sudo shutdown -c
```

Windows:

```powershell
shutdown /r /t 300 /c "Prueba del taller: no se reiniciará"
shutdown /a
```

## Evento 100 de Windows, opcional con administrador

El informe funciona sin administrador. Para añadir el desglose si el registro está disponible, abrir PowerShell como administrador y volver a ejecutar `informe_arranque.ps1`. Se conserva un informe por fecha y hora.

## Material y muestras

Se encontraron las dos bases y `muestras_logs_arranque.txt` en Descargas. Los scripts completan los esqueletos del docente. Ver `Analisis_muestras.md` para el reto de máquina B.
La ejecución del Laboratorio del Administrador y sus escenarios sigue pendiente; no se inventan resultados.
