# Resultados de Ubuntu

Ejecución realizada por el estudiante en VMware y revisada a partir de los archivos generados en la carpeta compartida. Equipo: `osboxes`; Ubuntu 25.04, núcleo `6.14.0-15-generic`, arquitectura `x86_64`.

## Informe de arranque

| Dato | Resultado |
|---|---|
| Núcleo | 8.477 s |
| Espacio de usuario | 17.506 s |
| Total informado por systemd | 25.984 s |
| Unidad más lenta en blame | plymouth-quit-wait.service, 7.114 s |
| Módulos cargados | 66 |
| Target | graphical.target |
| Unidades fallidas | Ninguna |

La salida no muestra una fase initrd separada ni tiempos de firmware o cargador; no se asignan valores a esas fases. La suma de los tiempos impresos puede diferir del total por redondeo.
`plymouth-quit-wait.service` también aparece en la cadena crítica: su duración no demuestra por sí sola la causa raíz de la espera y no se han modificado servicios.

## Talleres

- PID 1: systemd. Procesos: 308. CPU disponibles para la VM: 2.
- Servicios activos: 31.
- RAM: 5.2 GiB total; 3.3 GiB libre; 4.0 GiB disponible (valores redondeados por free).
- Swap: 3.8 GiB total; 0 B utilizada.
- Segunda muestra de vmstat: id=99 %, wa=0 %.
- Se obtuvo la ficha del módulo dummy, pero no se ejecutó su carga/descarga.
- El journal contiene advertencias `context mismatch in svga_surface_destroy` de Nautilus. Se conservan en la evidencia; no equivalen a unidades systemd fallidas ni se ha diagnosticado su causa.

## Espera y multiprogramación

Se calcula p=1−(user+sys)/real y n=ceil(log(0.1)/log(p)) con los valores sin redondear p. Es una estimación del modelo de la guía y no garantiza esa ocupación en el equipo real.

| Programa | real (s) | user (s) | sys (s) | p | n para U ≥ 90 % |
|---|---:|---:|---:|---:|---:|
| Espera automática (`sleep 2`) | 2.006 | 0.001 | 0.002 | 0.999 | 1539 |
| Cálculo (bucle Bash) | 1.926 | 1.919 | 0.001 | 0.003 | 1 |
| Lectura (`find /usr`) | 7.951 | 0.112 | 3.732 | 0.517 | 4 |

`sleep 2` sustituye automáticamente la espera de teclado; no es evidencia del `read` manual. La prueba `find` puede incluir espera de planificación, caché y permisos además de E/S; no mide exclusivamente el disco físico.

## Fecha y procedencia

Se conservan las marcas de tiempo originales: los talleres indican `2026-10-27T20:21:12-04:00`. La VM usa un desfase de UTC−04:00 en esa captura; corresponde a las 19:21:12 en Ecuador continental (UTC−05:00). No se cambia la hora de los archivos de evidencia.

## Archivos de evidencia

- [Informe de arranque](reportes/linux/informe_arranque_osboxes_20261027_202109_341594047.txt)
- [Talleres](reportes/linux/talleres_osboxes_20261027_202109_322550864.txt)
