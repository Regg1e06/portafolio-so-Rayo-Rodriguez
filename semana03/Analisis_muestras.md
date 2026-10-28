# Análisis de las muestras de clase

Fuente: `muestras_logs_arranque.txt`, entregado por el docente. El propio archivo dice que son ejemplos construidos para clase; no son mediciones de nuestro equipo.

## Máquina B

| Etapa | Máquina A (s) | Máquina B (s) | Diferencia B − A (s) |
|---|---:|---:|---:|
| Núcleo | 1.412 | 1.398 | -0.014 |
| initrd | 3.106 | 3.287 | 0.181 |
| Espacio de usuario | 9.847 | 38.912 | 29.065 |
| Total | 14.365 | 43.597 | 29.232 |

La diferencia se concentra en el espacio de usuario. En B, `mnt-respaldo.mount` tarda 25.021 s y está en la cadena crítica hacia `remote-fs.target`, `multi-user.target` y `graphical.target`. El registro indica que el servidor NFS 192.168.56.20 no responde inicialmente; `/etc/fstab` configura ese montaje con `defaults`.

Revisaríamos primero la disponibilidad y conectividad del servidor de respaldo y si ese recurso debe bloquear el inicio. Si fuera opcional, evaluaríamos un montaje bajo demanda y opciones de tolerancia a fallos; aquí no se modifica el equipo.

No basta con `blame`: las unidades arrancan en paralelo. En A, `NetworkManager-wait-online` tarda 6.104 s y no está en la cadena crítica. En B sí aparece como dependencia del montaje remoto. Antes de comparar con nuestro Ubuntu hay que ejecutar el informe y usar sus valores reales.

## Windows de referencia

Firmware: 7.400 s. Ruta principal: 15.210 s. Posarranque: 26.322 s. `BootTime` = 41.532 s = 15.210 + 26.322; no incluye sumar de nuevo el firmware. En esa muestra, posarranque es la mayor de las dos fases del evento 100.

El ejemplo de inicio rápido conserva `LastBootUpTime` tras apagar y encender porque recupera el núcleo hibernado. Después de Reiniciar cambia. Esto describe la muestra del docente; no prueba que se haya realizado esa prueba en nuestro PC.
