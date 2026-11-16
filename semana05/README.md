# Semana 05 · Seguridad del sistema

**Sistemas Operativos GR1 · Escuela Politécnica Nacional**
**Integrantes:** Miguel Rayo e Italo Rodríguez
**Fecha:** 16 de noviembre de 2026

## Deber 5 · Auditoría de seguridad

Los scripts revisan las cuentas privilegiadas, las escuchas TCP, el estado del cortafuegos y los fallos de inicio de sesión por IP. Imprimen el resultado de cada sección, guardan un TXT y devuelven **0** si todas las comprobaciones quedan en OK o **1** si hay una alerta o una consulta falla.

| Entorno | Script | Evidencia de ejecución |
| --- | --- | --- |
| AlmaLinux | [Bash](auditoria_seguridad.sh) | [Journal real, umbral 5, código 0](auditoria_linux.txt) · [Muestra, umbral 3, código 1](auditoria_linux_muestra.txt) |
| Windows PowerShell 5.1 | [PowerShell](auditoria_seguridad.ps1) | [CSV de práctica, umbral 3, código 1](auditoria_windows.txt) · [Umbral 5, código 0](auditoria_windows_umbral5.txt) |

### Ejecutar desde esta carpeta

```bash
bash ./auditoria_seguridad.sh
echo "$?"
bash ./auditoria_seguridad.sh -m muestras/muestra_sesion3_auth.log -u 3
echo "$?"
```

```powershell
.\auditoria_seguridad.ps1 -Muestra .\muestras\muestra_sesion3_4625.csv -Umbral 3
$LASTEXITCODE
```

Ejecutamos los dos scripts con cuentas normales. Bash consulta el journal de SSH de las últimas 24 horas si se omite `-m`. PowerShell acepta `-Muestra` para revisar los fallos cuando el registro Security requiere permisos. El umbral predeterminado es 5. Se puede elegir el archivo de salida con `-o` o `-Informe`.

## Ayuda memoria

[Comandos de Windows y Linux](Comandos.md) usados en los talleres y la auditoría.

## Muestras de práctica

Los archivos de [muestras](muestras/) reproducen en formato SSH y CSV los 11 fallos del ejercicio «El IDS a mano» de la sesión 3. Las horas, IP y usuarios se tomaron del ejercicio y se añadieron los campos necesarios para probar los scripts. El conteo por archivo es 4, 4 y 3. La ventana móvil de dos minutos del ejercicio es distinta del conteo de todos los fallos de un archivo o de las últimas 24 horas.

Codex apoyó la redacción de la ayuda memoria, la implementación de los scripts y la comprobación de las salidas.
