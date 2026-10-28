# =============================================================================
#  Deber 3 · Informe de arranque (Windows)           ESQUELETO COMPLETADO
#  Sistemas Operativos · EPN · Semana 3
# -----------------------------------------------------------------------------
#  Autores:   Miguel Rayo, Italo Rodriguez
#  Fecha:     2026-10-27
#  Uso de IA: ChatGPT/Codex para explicar comandos, completar y depurar los scripts.
# -----------------------------------------------------------------------------
#  Qué debe hacer: reunir en un archivo de texto cómo arrancó esta máquina.
#    Secciones 1, 2 y 3  → las empiezan en el Taller 2 (parte D).
#    Secciones 4, 5 y 6  → las terminan en casa.
#  Uso:       .\informe_arranque.ps1
#             Si Windows bloquea el script, una sola vez:
#             Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
#  Entrega:   guárdalo como semana03/informe_arranque.ps1 en el repositorio
#             de la pareja y súbelo a GitHub (instrucciones al final).
#
#  Cómo completar: reemplaza cada línea «"PENDIENTE ..."» por los comandos que
#  piden las pistas. Ejecuta el script después de cada sección.
# =============================================================================

$ErrorActionPreference = 'Stop'
$equipo = $env:COMPUTERNAME
$directorio = Join-Path $PSScriptRoot 'reportes\windows'
New-Item -ItemType Directory -Force $directorio | Out-Null
$salida = Join-Path $directorio ("informe_arranque_{0}_{1}.txt" -f $equipo, (Get-Date -Format 'yyyyMMdd_HHmmss_fff'))
function Seccion([string]$titulo, [scriptblock]$accion) {
    try { & $accion | Out-String -Width 220 } catch { "AVISO: $($_.Exception.Message)" }
}
$power  = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power'
$logDiag = 'Microsoft-Windows-Diagnostics-Performance/Operational'

function Titulo([string]$texto) {
    ""
    "=== $texto ==="
}

# Devuelve $true si la PowerShell se abrió como administrador.
function EsAdministrador {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Lee un dato con nombre (por ejemplo 'BootTime') de un evento del registro.
function DatoEvento($evento, [string]$nombre) {
    $xml = [xml]$evento.ToXml()
    ($xml.Event.EventData.Data | Where-Object { $_.Name -eq $nombre }).'#text'
}

# --- 1 · SO, versión y compilación -------------------- (Taller 2) ----------
function Seccion1 {
    Titulo "1 · Sistema operativo, versión y compilación"
    # Pista: $os = Get-CimInstance Win32_OperatingSystem
    #        Usa $os.Caption, $os.Version, $os.BuildNumber y $os.OSArchitecture.
# 1. Identificar sistema y versión del núcleo NT.
    Seccion '1 · SO, versión y núcleo' {
        Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,BuildNumber,OSArchitecture | Format-List
    }
}

# --- 2 · Último arranque y uptime --------------------- (Taller 2) ----------
function Seccion2 {
    Titulo "2 · Último arranque y tiempo encendido"
    # Pista: $os.LastBootUpTime es la fecha del último arranque completo.
    #        (Get-Date) - $os.LastBootUpTime da el tiempo encendido; usa sus
    #        propiedades .Days, .Hours y .Minutes.
# 2. Calcular tiempo transcurrido desde el arranque informado por Windows.
    Seccion '2 · Último arranque y uptime' {
        $so = Get-CimInstance Win32_OperatingSystem
        "Último arranque: $($so.LastBootUpTime.ToString('yyyy-MM-dd HH:mm:ss'))"
        "Tiempo encendido: $((Get-Date) - $so.LastBootUpTime)"
    }
}

# --- 3 · Desglose del arranque ------------------------ (Taller 2) ----------
function Seccion3 {
    Titulo "3 · Desglose del arranque"
    # Pista: el tiempo del firmware está en el registro:
    #        (Get-ItemProperty -Path $power -Name FwPOSTTime).FwPOSTTime  (ms)
    # Pista: el desglose del sistema es el evento 100 de $logDiag y necesita
    #        administrador. Si (EsAdministrador) es falso, muestra un aviso.
    #        $e = Get-WinEvent -FilterHashtable @{ LogName = $logDiag; Id = 100 } -MaxEvents 1
    #        DatoEvento $e 'BootTime' (también 'MainPathBootTime' y 'BootPostBootTime'), en ms.
# 3. Consultar firmware y desglose; cada fuente puede faltar por separado.
    Seccion '3 · Desglose del arranque' {
        try {
            $v=Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power'
            if ($null -ne $v.FwPOSTTime) { "Firmware: $($v.FwPOSTTime) ms ($($v.FwPOSTTime/1000) s)" }
            else { 'AVISO: FwPOSTTime no está expuesto por este equipo.' }
        } catch { "AVISO firmware: $($_.Exception.Message)" }
        if (EsAdministrador) {
            try {
                $e=Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Diagnostics-Performance/Operational';Id=100} -MaxEvents 1
                "Fecha del evento 100: $($e.TimeCreated) (puede corresponder a un arranque anterior)"
                ([xml]$e.ToXml()).Event.EventData.Data | Where-Object Name -in 'BootTime','MainPathBootTime','BootPostBootTime' | ForEach-Object { "$($_.Name): $($_.'#text') ms" }
            } catch { "AVISO evento 100: $($_.Exception.Message)" }
        } else { 'AVISO: evento 100 omitido: requiere PowerShell como administrador. Las otras secciones continúan.' }
    }
}

# --- 4 · Servicios y demoras -------------------------- (en casa) -----------
function Seccion4 {
    Titulo "4 · Servicios y demoras del arranque"
    # Pista: Get-CimInstance Win32_Service da todos los servicios.
    #        Cuenta los que tienen State 'Running' y lista hasta 5 que tengan
    #        StartMode 'Auto' pero no estén en ejecución.
    # Opcional (administrador): los eventos 101, 102 y 103 de $logDiag dicen
    #        qué componentes demoraron el arranque ('FriendlyName', 'TotalTime').
# 4. Windows no expone blame; usar el criterio específico de la guía.
    Seccion '4 · Servicios en ejecución y automáticos detenidos' {
        $servicios=Get-CimInstance Win32_Service
        $activos=@($servicios | Where-Object State -eq 'Running')
        "En ejecución: $($activos.Count)"
        $activos | Sort-Object Name | Select-Object -First 5 Name,DisplayName,StartMode | Format-Table -AutoSize
        'Automáticos detenidos (no implica por sí solo una avería):'
        $detenidos=@($servicios | Where-Object { $_.StartMode -eq 'Auto' -and $_.State -ne 'Running' })
        "Total: $($detenidos.Count)"
        $detenidos | Sort-Object Name | Select-Object -First 5 Name,State,StartMode | Format-Table -AutoSize
    }
}

# --- 5 · Controladores -------------------------------- (en casa) -----------
function Seccion5 {
    Titulo "5 · Controladores (drivers)"
    # Pista: driverquery /fo csv | ConvertFrom-Csv  → cuenta los controladores.
    #        Get-CimInstance Win32_SystemDriver → cuenta los que están 'Running'.
# 5. Consultar las dos fuentes pedidas por la guía, sin cambios al sistema.
    Seccion '5 · Módulos y controladores' {
        try {
            $dq=@(driverquery.exe /fo csv | ConvertFrom-Csv)
            if ($LASTEXITCODE -ne 0) { throw 'driverquery terminó con error.' }
            "Total driverquery: $($dq.Count)"
            $dq | Select-Object -First 8 | Format-Table -AutoSize
        } catch { "AVISO driverquery: $($_.Exception.Message)" }
        $drivers=@(Get-CimInstance Win32_SystemDriver | Where-Object State -eq 'Running')
        "Win32_SystemDriver en ejecución: $($drivers.Count)"
        $drivers | Sort-Object Name | Select-Object -First 5 Name,State,StartMode | Format-Table -AutoSize
    }
}

# --- 6 · Inicio rápido -------------------------------- (en casa) -----------
function Seccion6 {
    Titulo "6 · Inicio rápido"
    # Pista: (Get-ItemProperty -Path $power -Name HiberbootEnabled).HiberbootEnabled
    #        vale 1 si el inicio rápido está activado y 0 si no.
# 6. Estado del inicio rápido; no modifica el registro ni apaga el equipo.
    Seccion '6 · Cierre e inicio rápido' {
        $v=Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power'
        if ($null -eq $v.HiberbootEnabled) { 'AVISO: HiberbootEnabled no está disponible.' }
        else { "HiberbootEnabled: $($v.HiberbootEnabled) (1=configurado; 0=desactivado). Consultar powercfg /a para disponibilidad." }
        powercfg.exe /a
    }
}

$informe = & {
    "Informe de arranque · $equipo · $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    "Autores: Miguel Rayo, Italo Rodriguez | IA: ChatGPT/Codex para completar y depurar scripts."
    "Administrador: $(EsAdministrador) | Captura: $(Get-Date -Format o)"
    Seccion1
    Seccion2
    Seccion3
    Seccion4
    Seccion5
    Seccion6
}
$informe | Set-Content -LiteralPath $salida -Encoding UTF8
$informe
""
"Informe guardado en: $salida"

# -----------------------------------------------------------------------------
#  Subir al portafolio (GitHub), desde la carpeta del repositorio de la pareja:
#    git pull
#    git add semana03/informe_arranque.ps1
#    git commit -m "Semana 3: informe de arranque (Windows), secciones 1-3"
#    git push
#  Haz un commit al terminar el taller y otro al terminar en casa.
#  Cada integrante hace al menos un commit con su parte (criterio de la rúbrica).
# -----------------------------------------------------------------------------

