# Deber 4 · Verificador de entorno · Sistemas Operativos GR1 · EPN
# Autores: Miguel Rayo e Italo Rodríguez
# Fecha: 2026-11-15
# Uso de IA: ChatGPT/Codex apoyó la implementación, depuración y pruebas.
# Uso: .\verificador_entorno.ps1. Guarda el informe en el directorio actual.
# Salida: 0 si están todas las herramientas, 1 si falta alguna o falla el informe.

$requeridas = [ordered]@{
    'git' = 'Git.Git'
    'curl.exe' = 'cURL.cURL'
    'python' = 'Python.Python.3.12'
    'jq' = 'jqlang.jq'
    'winget' = 'Microsoft.AppInstaller'
}
$script:faltan = @()
$script:rutasValidas = @{}
$equipo = $env:COMPUTERNAME
$marca = Get-Date -Format 'yyyyMMdd_HHmmss_fffffff'
$salida = "verificador_${equipo}_$marca.txt"

function Titulo([string]$Texto) {
    ''
    "=== $Texto ==="
}

# 1. Identifica Windows y la edición y versión de PowerShell.
function Seccion1 {
    Titulo '1 · Sistema y shell'
    try {
        $so = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        "Sistema: $($so.Caption) (compilación $($so.BuildNumber))"
    } catch {
        "Sistema: $([Environment]::OSVersion.VersionString)"
        'AVISO: no se pudo consultar Win32_OperatingSystem.'
    }
    "PowerShell: $($PSVersionTable.PSVersion) ($($PSVersionTable.PSEdition))"
    "Usuario: $env:USERNAME"
}

# Omite alias de PowerShell y accesos vacíos de Python que abren Microsoft Store.
function Buscar([string]$Nombre) {
    Get-Command $Nombre -CommandType Application -All -ErrorAction SilentlyContinue |
        Where-Object {
            if ($Nombre -eq 'python' -and $_.Source -like '*\WindowsApps\python*.exe') {
                $archivo = Get-Item -LiteralPath $_.Source -Force -ErrorAction SilentlyContinue
                $archivo -and $archivo.Length -gt 0
            } else {
                $true
            }
        } | Select-Object -First 1
}

# 2. Comprueba la versión de cada ejecutable y registra su ruta y estado.
function Seccion2 {
    Titulo '2 · Herramientas requeridas'
    $filas = foreach ($nombre in $requeridas.Keys) {
        $aplicacion = Buscar $nombre
        $ruta = '-'
        $version = 'Fuera del PATH'
        $estado = 'FALTA'
        if ($aplicacion) {
            $ruta = $aplicacion.Source
            try {
                $respuesta = & $ruta --version 2>&1
                if ($LASTEXITCODE -eq 0 -and $respuesta) {
                    $estado = 'OK'
                    $version = [string]($respuesta | Select-Object -First 1)
                    $script:rutasValidas[$nombre] = $ruta
                } else {
                    $version = 'Falló la consulta de versión'
                }
            } catch {
                $version = 'Error al ejecutar el programa'
            }
        }
        if ($estado -eq 'FALTA') { $script:faltan += $nombre }
        [pscustomobject]@{ Comando = $nombre; Estado = $estado; Ruta = $ruta; Version = $version }
    }
    $filas | Format-Table -AutoSize -Wrap | Out-String -Width 220
}

function ProgramasInstalados {
    $claves = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
              'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
              'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    Get-ItemProperty -Path $claves -ErrorAction SilentlyContinue | Where-Object DisplayName
}

# 3. Cuenta las entradas de desinstalación y muestra las fuentes de WinGet.
function Seccion3 {
    Titulo '3 · Programas instalados y orígenes de WinGet'
    "Entradas del registro con nombre: $($programas.Count)"
    if ($script:rutasValidas.ContainsKey('winget')) {
        $winget = $script:rutasValidas['winget']
        try {
            $origenes = & $winget source list 2>&1
            $codigoWinget = $LASTEXITCODE
            $origenes | ForEach-Object { [string]$_ }
            if ($codigoWinget -ne 0) {
                "AVISO: winget source list terminó con código $codigoWinget."
            }
        } catch {
            "AVISO: no se pudieron consultar los orígenes: $($_.Exception.Message)"
        }
    } else {
        'AVISO: WinGet no está disponible para consultar sus orígenes.'
    }
}

# 4. Ordena de más reciente a más antigua usando las fechas AAAAMMDD.
function Seccion4 {
    Titulo '4 · Últimas 5 instalaciones registradas'
    $recientes = @($programas | Where-Object { $_.InstallDate -match '^\d{8}$' } |
        Sort-Object InstallDate -Descending |
        Select-Object -First 5 InstallDate, DisplayName, DisplayVersion)
    if ($recientes.Count -eq 0) {
        'Sin instalaciones con fecha visible en el registro.'
    } else {
        $recientes | Format-Table -AutoSize -Wrap | Out-String -Width 220
    }
}

# 5. Propone los comandos de instalación para las herramientas faltantes.
function Seccion5 {
    Titulo '5 · Qué falta y cómo instalarlo'
    if ($script:faltan.Count -eq 0) {
        'Todas las herramientas requeridas están disponibles.'
        return
    }
    "Herramientas faltantes: $($script:faltan -join ', ')"
    if ('winget' -in $script:faltan) {
        'Instala o repara Instalador de aplicación (Microsoft.AppInstaller) en Microsoft Store.'
        'Abre otra terminal y comprueba winget --version antes de usar los comandos.'
    }
    $comandos = foreach ($nombre in $script:faltan) {
        if ($nombre -ne 'winget') {
            "winget install --id $($requeridas[$nombre]) -e"
        }
    }
    if ($comandos) { $comandos -join '; ' }
}

# 6. Resume el diagnóstico y muestra el estado que devuelve el script.
function Seccion6 {
    Titulo '6 · Resultado'
    "Herramientas listas: $($requeridas.Count - $script:faltan.Count) de $($requeridas.Count)"
    "Código de salida: $([int]($script:faltan.Count -gt 0))"
}

$programas = @(ProgramasInstalados)
$informe = & {
    "Verificador de entorno · $equipo · $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz')"
    Seccion1
    Seccion2
    Seccion3
    Seccion4
    Seccion5
    Seccion6
}
try {
    $informe | Set-Content -LiteralPath $salida -Encoding UTF8 -ErrorAction Stop
} catch {
    Write-Error "No se pudo guardar el informe: $($_.Exception.Message)"
    exit 1
}
$informe
''
"Informe guardado en: $salida"
exit ([int]($script:faltan.Count -gt 0))
