# Semana 04 · Llamadas al sistema y verificación del entorno

**Sistemas Operativos GR1 · Escuela Politécnica Nacional**  
**Integrantes:** Miguel Rayo e Italo Rodríguez

## Deber 4

Los dos verificadores consultan el sistema, comprueban las herramientas, enumeran paquetes y orígenes, muestran las últimas instalaciones visibles, dan comandos para preparar el entorno y devuelven un código de salida. Generan un informe TXT en el directorio desde el que se ejecutan y funcionan con una cuenta normal.

| Plataforma | Script | Herramientas |
| --- | --- | --- |
| Linux | [verificador_entorno.sh](verificador_entorno.sh) | `git`, `curl`, `python3`, `jq`, `strace`, `tree` |
| Windows | [verificador_entorno.ps1](verificador_entorno.ps1) | `git`, `curl.exe`, `python`, `jq`, `winget` |

### Ejecutar

Desde la raíz del portafolio, entra a `semana04/` para guardar ahí los resultados.

**Linux (Bash)**

```bash
cd semana04
bash ./verificador_entorno.sh
echo "$?"
```

**Windows (PowerShell)**

```powershell
Set-Location .\semana04
.\verificador_entorno.ps1
$LASTEXITCODE
```

Si la política local bloquea el archivo, se puede ejecutar en un proceso de Windows PowerShell con `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\verificador_entorno.ps1`. El alcance de esa opción es el proceso nuevo.

El código **0** indica que todas las herramientas respondieron a la consulta de versión. El código **1** indica que falta alguna, que una herramienta detectada no pudo ejecutarse o que el informe no pudo guardarse.

### Informes reales del 15 de noviembre de 2026

| Entorno | Resultado | Salida | Evidencia |
| --- | --- | --- | --- |
| Ubuntu 25.04 en la VM del curso | 3 de 6. Faltan `git`, `curl` y `tree`. | `1` | [Informe de Ubuntu](verificador_osboxes_20261115_111339_Y7uXRN.txt) |
| Windows 11 con Windows PowerShell 5.1 | 5 de 5. Se leyó el PATH persistente del equipo y `jq` respondió. | `0` | [Informe de Windows](verificador_DESKTOP-DRKOFCJ_20261115_111432_9292224.txt) |

El verificador de Linux incluye DNF/RPM para AlmaLinux y APT/dpkg para Ubuntu. Se ejecutó en la VM Ubuntu. En Ubuntu, el informe muestra el propietario del binario y la política local de versiones y fuentes de APT. En Windows, la lista de instalaciones se limita a las entradas del registro que tienen fecha.

## Talleres

- [Hoja de resultados de los talleres 1 y 2](talleres/Talleres_1_y_2.pdf), con las mediciones de la pareja del 11 de noviembre.
- [Complemento de los talleres](talleres/Resultados_y_comandos.md), con los comandos del reto, la interpretación de las mediciones y la comprobación de `jq`.

## Publicación en el portafolio

Coloca `semana04/` junto a `semana03/`. Cada integrante debe hacer un commit con su verificador y su informe, usando su propia cuenta de GitHub. Si ya existe un commit de las secciones 1–3 en su copia de trabajo, consérvenlo y registren la versión final en el siguiente commit. Publiquen el taller y este README con los archivos de la semana.

Fila para agregar a la tabla del README principal:

```markdown
| [Semana 4](semana04/) | Llamadas al sistema, tuberías y gestores de paquetes | Verificador de entorno en Bash y PowerShell; talleres 1 y 2 |
```

## Uso de IA

Se usó ChatGPT/Codex para completar y depurar los scripts a partir de los esqueletos de la materia, agregar el soporte de Ubuntu, verificar las salidas y organizar la entrega. Las mediciones del PDF corresponden al trabajo de la pareja.

