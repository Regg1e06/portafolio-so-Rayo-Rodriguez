# Apuntes - Modelo de programación, memoria y datos

## Modelo de programación

Es lo que la CPU deja ver y utilizar al programa: registros, instrucciones de la ISA, banderas, modos de ejecución y mecanismos de pila e interrupciones. La caché es parte de la organización interna; el programa influye en su rendimiento mediante el orden de los accesos.

En x86-64, RIP indica la siguiente instrucción, RSP señala la cima de la pila y RFLAGS contiene las banderas. RAX es un registro general que también se usa para devolver resultados. EAX, AX y AL son partes de ese registro de diferente ancho.

Las aplicaciones trabajan normalmente en modo usuario. Las llamadas al sistema, excepciones e interrupciones permiten entrar al código del núcleo por mecanismos definidos por el SO. Eso protege recursos que una aplicación no debería controlar directamente.

La pila funciona como LIFO: lo último que entra es lo primero que sale. En una llamada x86, `CALL` guarda una dirección de retorno y transfiere el control; `RET` recupera esa dirección. La demo [suma.c](clases/suma.c) permite observar cómo el compilador organiza una función. Los registros de argumentos varían entre Linux y Windows.

## Representación de datos

Los bits necesitan una interpretación: ancho, signo, tipo y orden de bytes. El patrón `0x9C` vale 156 sin signo y −100 en complemento a 2 de 8 bits.

Para representar −100 en 8 bits: 100 = `0110 0100`; se invierten los bits, `1001 1011`, y se suma 1: `1001 1100` = `0x9C`. En 32 bits es `0xFFFFFF9C`.

| Bandera | Qué indica en una suma de ancho fijo |
| --- | --- |
| CF | Sale un acarreo del bit más alto; desbordamiento sin signo |
| OF | Dos operandos del mismo signo producen un resultado del signo contrario |
| ZF | Todos los bits del resultado son cero |
| SF | Copia del bit de signo del resultado |

En little-endian se guarda primero el byte menos significativo. `0x12345678` queda como `78 56 34 12`. En big-endian queda `12 34 56 78`. El orden de bytes no invierte los bits dentro de cada byte.

UTF-8 representa caracteres con uno a cuatro bytes: `A` ocupa uno; `ñ`, dos. En IEEE 754 de precisión simple se usan 1 bit de signo, 8 de exponente y 23 de fracción. `0.5` tiene una representación binaria finita; `0.1` y `0.3` necesitan redondeo.

## Jerarquía y localidad

La jerarquía va de registros a cachés L1/L2/L3, RAM y almacenamiento. Los niveles cercanos a la CPU tienen menor capacidad y menor latencia. La localidad temporal consiste en volver a usar un dato reciente; la espacial, en usar datos cercanos en memoria.

C guarda una matriz por filas. Para enteros de 4 bytes y una línea de 64 bytes, caben 16 enteros por línea. Recorrer por filas aprovecha esos vecinos; por columnas puede saltar miles de bytes entre accesos.

Ejemplo de geometría: C = 32 KiB, L = 64 bytes, A = 8 vías.

```text
S = 32768 / (64 * 8) = 64 conjuntos
desplazamiento = log2(64) = 6 bits
índice = log2(64) = 6 bits
etiqueta, en el ejemplo de direcciones de 32 bits = 32 - 6 - 6 = 20 bits
```

Para Tc = 1 ns, Tm = 100 ns y h = 0.9375:

```text
Tmedio = Tc + (1-h)*Tm
       = 1 + (1-0.9375)*100
       = 7.25 ns
```

Estos nanosegundos pertenecen al modelo del simulador. Los segundos impresos por `matriz.c` miden la ejecución de un recorrido completo y no equivalen a esa latencia media.

## Relación con la asignatura

La semana 2 cierra el primer acto del hilo narrativo: conocer el hardware y sus límites. Los modos usuario/núcleo explican la base de la protección; los datos explican cómo se interpreta la memoria; la localidad explica por qué dos programas que calculan lo mismo pueden tardar distinto. Estos conceptos preparan el estudio del sistema operativo, sus procesos y la gestión de recursos.

Material base: diapositivas de la semana 2, hilo narrativo y guía de laboratorio entregados por el docente.
