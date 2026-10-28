# Estado de ejecución

## Windows

Ejecutado el 27 de octubre de 2026 en el equipo real, sin PowerShell de administrador. Los `.txt` de `reportes/windows/` contienen la captura de la versión final de los scripts.
Se verificaron las seis secciones del informe y las consultas/mediciones de los talleres. El evento 100 se omite con un aviso porque requiere administrador; no se sustituyó por datos de muestra.

El informe muestra Windows 11 Home, compilación 26200. El firmware informa 4744 ms (4.744 s). Estos datos describen la captura, no un valor fijo para futuras ejecuciones. La RAM libre, CPU ociosa, procesos, servicios y tiempos de los programas cambian entre ejecuciones.

Los scripts PowerShell tienen codificación UTF-8 con BOM para conservar los acentos en Windows PowerShell 5.1. Se comprobó su sintaxis y su ejecución real.

## Ubuntu

El estudiante ejecutó los scripts en Ubuntu 25.04 dentro de VMware. Se revisaron los dos archivos de la carpeta compartida: el informe contiene las seis secciones y el archivo de talleres incluye las consultas y tres mediciones. Se conservaron las salidas originales en `reportes/linux/`. Ver `Resultados_Ubuntu.md` para el resumen y los cálculos de p y n.

El arranque informa 25.984 s y ninguna unidad fallida. El journal sí contiene advertencias de Nautilus, conservadas en el archivo de talleres; ambas observaciones pueden coexistir.

## Pendientes de la pareja

- Realizar las prácticas manuales si se entregan también los talleres.
- Completar la actividad del Laboratorio del Administrador con sus resultados reales.
- Hacer un commit por integrante desde su propia cuenta y verificar el historial de GitHub.

Los scripts del deber completan las bases originales de Descargas. Las muestras del docente se analizan aparte en `Analisis_muestras.md` y no se presentan como evidencia del equipo.

## Observación sobre la medición de cálculo

La captura del bucle de PowerShell obtuvo real=3.154613 s y CPU=3.218750 s, dando p=-0.020. Se conserva esa salida real: no se fuerza a cero ni se usa para calcular n. El tiempo de CPU suma los hilos del proceso y la resolución/variación de la medición limita esta estimación. El resultado no admite una interpretación como probabilidad de espera dentro del modelo de un solo flujo. La prueba ping obtuvo p=0.985 y dir obtuvo p=0.498 en esa captura; pueden variar.
