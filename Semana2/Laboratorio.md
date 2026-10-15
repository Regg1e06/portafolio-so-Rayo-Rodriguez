# Laboratorio de memoria y caché - Semana 2

## Procedencia de los resultados

Los valores de caché de este documento se reprodujeron ejecutando las funciones de generación de accesos y caché del archivo `Laboratorio_Memoria_Cache.html` entregado por el docente. Son **resultados del modelo del simulador**, con caché inicialmente vacía, Tc = 1 ns, Tm = 100 ns y política LRU. La [salida del modelo](reportes/comprobaciones/salida_simulacion_cache.txt) conserva los valores obtenidos. No son mediciones físicas del computador ni capturas de una sesión Linux.

Las respuestas de datos se comprobaron con [datos.py](clases/datos.py), mediante aritmética modular, UTF-8 y conversión IEEE 754. La salida está en [salida_datos_python.txt](reportes/comprobaciones/salida_datos_python.txt). Las predicciones personales previas de la pareja no se reconstruyen después de conocer los resultados.

## Experimento 1 - Matriz por filas

Configuración: matriz de 64 × 64 enteros de 4 bytes, C = 1 KiB, L = 64 bytes y A = 2.

| Dato | Resultado simulado |
| --- | ---: |
| Accesos | 4096 |
| Aciertos | 3840 |
| Fallos | 256 |
| h | 93.75 % |
| Tmedio | 7.25 ns |
| Frecuencia de fallo | 1 cada 16 accesos |

Una línea contiene 64/4 = 16 enteros. El primero provoca un fallo obligatorio y los siguientes 15 aprovechan la misma línea. Aumentar la capacidad no elimina ese primer acceso a un bloque que todavía no se ha traído.

## Experimento 2 - Matriz por columnas

Se conserva L = 64 bytes y A = 2. Solo varía la capacidad.

| C | h simulado | Tmedio simulado |
| --- | ---: | ---: |
| 1 KiB | 0 % | 101 ns |
| 2 KiB | 0 % | 101 ns |
| 4 KiB | 0 % | 101 ns |
| 8 KiB | 0 % | 101 ns |
| 16 KiB | 93.75 % | 7.25 ns |

La matriz ocupa 64 × 64 × 4 = 16384 bytes = 16 KiB. En estas configuraciones, la línea se expulsa antes de reutilizarla hasta que caben todos los datos. Por eso el cambio es brusco. El recorrido por filas ya conseguía 93.75 % con 1 KiB; el recorrido por columnas necesitó 16 KiB en este caso.

## Experimento 3 - Conflicto

Configuración D: C = 4096 bytes, L = 32 bytes, dos arreglos de 2048 bytes separados por 4096 bytes; dos pasadas alternando a[i] y b[i].

| Vías | Accesos | Aciertos | Fallos | h | Tmedio |
| --- | ---: | ---: | ---: | ---: | ---: |
| 1 | 2048 | 0 | 2048 | 0 % | 101 ns |
| 2 | 2048 | 1920 | 128 | 93.75 % | 7.25 ns |

Con una vía hay 4096/32 = 128 conjuntos. La separación corresponde a 128 bloques y conserva el índice: `bloque % 128`. En el modelo, a[0] y b[0] caen en el conjunto 0 y se expulsan al alternar. Con dos vías pueden permanecer ambas líneas en el conjunto.

Un cambio del programa consiste en procesar primero un bloque de a[] y luego uno de b[], usando cada línea antes de cambiar de arreglo. También se puede revisar el alineamiento y añadir separación que reduzca los conflictos. Con una sola vía, LRU, FIFO y aleatorio tienen la misma única opción de reemplazo.

## Experimento 4 - Stride de 64 bytes

Se recorren dos veces 16 KiB, con C = 4 KiB y A = 2.

| L | Accesos | Aciertos | Fallos | h | Tmedio |
| --- | ---: | ---: | ---: | ---: | ---: |
| 64 bytes | 512 | 0 | 512 | 0 % | 101 ns |
| 128 bytes | 512 | 256 | 256 | 50 % | 51 ns |

Con líneas de 64 bytes, cada salto cae en un bloque distinto. Con 128 bytes, dos accesos consecutivos separados por 64 bytes usan la misma línea: el segundo acierta. Hacer líneas mucho mayores reduce la cantidad de líneas disponibles y puede traer datos innecesarios; además, la transferencia de cada fallo puede costar más, aunque aquí Tm se mantiene fijo por simplicidad.

## Experimento 5 - Filtro de imagen

Configuración E: matriz 1024 × 1024 de 4 bytes, C = 32 KiB, L = 64 bytes y A = 8.

| Recorrido | Accesos | Aciertos | Fallos | h | Tmedio |
| --- | ---: | ---: | ---: | ---: | ---: |
| Columnas | 1048576 | 0 | 1048576 | 0 % | 101 ns |
| Filas | 1048576 | 983040 | 65536 | 93.75 % | 7.25 ns |

La imagen ocupa 4 MiB. La separación vertical es 1024 × 4 = 4096 bytes. Cambiar el orden de los bucles modifica el programa y aprovecha la localidad sin ampliar la caché. El cociente del tiempo medio modelado es 101/7.25 ≈ 13.93.

El escenario simula un recorrido de la matriz; no ejecuta todas las lecturas y escrituras de un filtro de desenfoque real. Tampoco garantiza una aceleración de 13.93 veces en el programa C completo.

Un ejemplo similar es calcular promedios por materia en una tabla guardada por alumno. En vez de recorrer todos los alumnos de cada materia, se recorre la fila de cada alumno y se acumula simultáneamente la suma de cada materia.

## Resumen de los cambios

| Experimento | Cambio | Categoría | h |
| --- | --- | --- | --- |
| A | Referencia por filas | Programa de referencia | 93.75 % |
| B | C de 1 a 16 KiB | Configuración de hardware simulada | 0 → 93.75 % |
| D | 1 a 2 vías | Configuración de hardware simulada | 0 → 93.75 % |
| C | Línea de 64 a 128 bytes | Configuración de hardware simulada | 0 → 50 % |
| E | Columnas a filas | Programa | 0 → 93.75 % |

## Ejercicio 6.1 - Complemento a 2 y banderas

Cada resultado de la tabla se interpreta con signo. Las banderas se calculan sobre los patrones del ancho elegido.

| A + B | 8 bits: resultado; CF OF ZF SF | 16 bits: resultado; CF OF ZF SF |
| --- | --- | --- |
| 127 + 1 | −128; 0 1 0 1 | 128; 0 0 0 0 |
| 200 + 100 | 44; 1 0 0 0 | 300; 0 0 0 0 |
| −50 + (−100) | 106; 1 1 0 0 | −150; 1 0 0 1 |
| −128 + (−128) | 0; 1 1 1 0 | −256; 1 0 0 1 |

127 + 1 excede 127, el máximo con signo de 8 bits; 128 sí cabe en 16 bits. En 200 + 100, CF = 1 detecta que 300 supera 255 sin signo. **200 ya no es un operando válido con signo en 8 bits:** el patrón 0xC8 significa −56; por eso OF = 0 corresponde a −56 + 100 = 44 y no demuestra que 200 + 100 sea una suma con signo válida. Para sumar tamaños sin signo se revisa CF o se valida el límite antes de sumar.

## Ejercicio 6.2 - Endianness, texto y reales

| Dirección | Little-endian de 0xCAFEBABE | Big-endian |
| --- | --- | --- |
| 0x1000 | BE | CA |
| 0x1001 | BA | FE |
| 0x1002 | FE | BA |
| 0x1003 | CA | BE |

`¿Señal? 5 €` contiene **11 caracteres y 15 bytes UTF-8**. `¿` y `ñ` usan dos bytes cada uno; `€`, tres. Los demás caracteres del ejemplo usan uno.

| Entrada | Float32 almacenado | Error frente al decimal exacto |
| --- | --- | --- |
| 0.1 | 0.100000001490116119384765625 | +1.490116119384765625 × 10⁻⁹ |
| 0.5 | 0.5 | 0 |
| 0.3 | 0.300000011920928955078125 | +1.1920928955078125 × 10⁻⁸ |

El script muestra la diferencia respecto al valor `float64` de Python, por eso sus últimos dígitos de error pueden variar frente a la resta decimal exacta de la tabla. 0.5 = 2⁻¹; los decimales 0.1 y 0.3 tienen expansión binaria infinita y se redondean.

Si un emisor little-endian envía los bytes de 0xCAFEBABE sin convertir a orden de red y el receptor los lee en big-endian, interpretará **0xBEBAFECA**.

## Demo de matriz en el equipo

La medición real incluida está en [salida_matriz_windows.txt](reportes/windows/salida_matriz_windows.txt). Ambos recorridos sumaron **68 702 699 520**. La comparación muestra el efecto del orden de acceso en esa ejecución; el tiempo depende del equipo, la carga y el compilador. No se incorporaron tiempos Linux porque esa ejecución está pendiente.

## Conclusiones

1. El modelo de programación define los recursos que usa una aplicación. Los modos de ejecución permiten al SO proteger los recursos que requieren privilegios; la pila conserva el retorno de las llamadas.
2. Los mismos bytes pueden tener significados distintos. El caso 200 + 100 en 8 bits muestra que hay que comprobar tanto el rango de entrada como la bandera correspondiente a su interpretación.
3. La localidad puede cambiar el rendimiento sin ampliar la memoria. En el modelo del filtro, cambiar columnas por filas elevó h de 0 a 93.75 % y redujo Tmedio de 101 a 7.25 ns. La demo C permite comparar ese principio con una medición real de un programa completo.
