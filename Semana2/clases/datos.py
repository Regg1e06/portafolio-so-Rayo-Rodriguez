#!/usr/bin/env python3
"""Demos de datos de las diapositivas y comprobaciones de la guia.
Las banderas se calculan con aritmetica modular; no se leen de una CPU real.
Python 3, solo biblioteca estandar. Uso: python3 datos.py [carpeta_generados]
"""
from pathlib import Path
import struct
import sys

destino = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).parent / 'generados'
destino.mkdir(parents=True, exist_ok=True)
print('== Archivos de la demo ==')
archivos = {'t.txt': 'Año\n'.encode('utf-8'), 'n.bin': struct.pack('<i', -100),
            'datos.bin': bytes.fromhex('2c010000feff41c3b16f203230323600')}
for nombre, contenido in archivos.items():
    (destino / nombre).write_bytes(contenido)
    print(nombre, ':', contenido.hex(' ').upper())

print('\n== Reto de volcado hexadecimal ==')
b = archivos['datos.bin']
texto = b[6:].split(b'\0', 1)[0]
print('uint32 little-endian, offset 0:', struct.unpack_from('<I', b, 0)[0])
print('int16 little-endian, offset 4:', struct.unpack_from('<h', b, 4)[0])
print('UTF-8:', texto.decode('utf-8'), '| caracteres:', len(texto.decode('utf-8')), '| bytes:', len(texto))
print('uint32 big-endian, offset 0:', struct.unpack_from('>I', b, 0)[0])

print('\n== Sumas y banderas simuladas ==')
for ancho in (8,16):
    modulo = 1 << ancho
    signo = 1 << (ancho - 1)
    for a, b in ((127,1),(200,100),(-50,-100),(-128,-128)):
        ua, ub = a % modulo, b % modulo
        r = (ua + ub) % modulo
        rs = r if r < signo else r - modulo
        cf = int(ua + ub >= modulo)
        of = int(bool(ua & signo) == bool(ub & signo) and bool(r & signo) != bool(ua & signo))
        print(f'{ancho} bits: {a:+d} + ({b:+d}) = {rs} con signo / {r} sin signo; CF={cf} OF={of} ZF={int(r==0)} SF={int(bool(r&signo))}')
print('En 8 bits, 200 no cabe CON signo: su patron 0xC8 se interpreta como -56.')

print('\n== Endianness y UTF-8 ==')
for orden, formato in (('little','<I'),('big','>I')):
    print('0xCAFEBABE', orden, ':', struct.pack(formato, 0xCAFEBABE).hex(' ').upper())
texto = '¿Señal? 5 €'
print(repr(texto), ':', len(texto), 'caracteres y', len(texto.encode('utf-8')), 'bytes')
for c in texto:
    print(repr(c), ':', c.encode('utf-8').hex(' ').upper())

print('\n== IEEE 754 precision simple ==')
for x in (0.1,0.5,0.3):
    datos = struct.pack('>f', x)
    guardado = struct.unpack('>f', datos)[0]
    print(f'{x}: 0x{datos.hex().upper()}, guardado={guardado:.17g}, error(float32-float64)={guardado-x:.17g}')
print('Doble precision: 0.1+0.2 =', repr(0.1+0.2))
