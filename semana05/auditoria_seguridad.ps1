<#
Miguel Rayo e Italo Rodríguez | Sistemas Operativos GR1 | 16/11/2026
IA: Codex apoyó la redacción, implementación y comprobación del script.
#>
[CmdletBinding()]
param(
    [string]$Muestra,
    [ValidateRange(1,999999999)][int]$Umbral = 5,
    [string]$Informe = ('auditoria_windows_{0}_{1}.txt' -f (Get-Date -Format yyyyMMdd_HHmmss), ([guid]::NewGuid().ToString('N').Substring(0,8)))
)

$ErrorActionPreference = 'Stop'
if ($Muestra) {
    if (!(Test-Path -LiteralPath $Muestra -PathType Leaf)) {
        Write-Error "Muestra inexistente: $Muestra" -ErrorAction Continue
        exit 1
    }
    $rutaInforme = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Informe)
    if ((Resolve-Path -LiteralPath $Muestra).ProviderPath -eq $rutaInforme) {
        Write-Error 'La muestra y el informe deben ser archivos distintos.' -ErrorAction Continue
        exit 1
    }
}

function Get-Llavero {
    # El RID 500 identifica al administrador integrado, aun si cambia su nombre.
    $miembros = @(Get-LocalGroupMember -SID 'S-1-5-32-544')
    $integrado = @(Get-LocalUser | Where-Object { $_.SID.Value -match '-500$' })
    $nombres = $miembros | ForEach-Object { $_.Name -replace '^.*\\', '' }
    if ($integrado.Count -ne 1) { throw 'No se pudo identificar la cuenta integrada local.' }
    $detalle = @(('Administradores: ' + ($nombres -join ', ')), ('Cuenta integrada habilitada: {0}' -f $integrado[0].Enabled))
    [pscustomobject]@{ Alerta = [bool]$integrado[0].Enabled; Detalle = $detalle }
}

function Get-Puertas {
    # Un puerto de la lista se marca si escucha fuera de loopback.
    $escuchas = @(Get-NetTCPConnection -State Listen)
    $riesgos = @($escuchas | Where-Object {
        $ip = [ipaddress]$_.LocalAddress
        if ($ip.IsIPv4MappedToIPv6) { $ip = $ip.MapToIPv4() }
        $_.LocalPort -in 21,23,3306,3389,5900 -and ![ipaddress]::IsLoopback($ip)
    })
    $detalle = @("Sockets TCP en escucha: $($escuchas.Count)")
    $detalle += @($escuchas | Sort-Object LocalPort,LocalAddress | ForEach-Object { "  [$($_.LocalAddress)]:$($_.LocalPort)" })
    $detalle += if ($riesgos.Count) {
        $riesgos | ForEach-Object { "Escucha de riesgo: [$($_.LocalAddress)]:$($_.LocalPort)" }
    } else { 'Escuchas de riesgo fuera de loopback: ninguna' }
    [pscustomobject]@{ Alerta = ($riesgos.Count -gt 0); Detalle = $detalle }
}

function Get-Portero {
    # Cualquier perfil deshabilitado activa la alerta.
    $perfiles = @(Get-NetFirewallProfile)
    if (!$perfiles.Count) { throw 'Consulta sin perfiles.' }
    $detalle = @($perfiles | ForEach-Object { "$($_.Name): habilitado=$($_.Enabled)" })
    [pscustomobject]@{ Alerta = (@($perfiles | Where-Object { !$_.Enabled }).Count -gt 0); Detalle = $detalle }
}

function Get-Fallos {
    # Los eventos 4625 con IP válida se agrupan por dirección de origen.
    if ($Muestra) {
        $detalle = @("Fuente: muestra $(Split-Path -Leaf $Muestra)")
        $filas = @(Import-Csv -LiteralPath $Muestra)
        if ($filas.Count -and (!$filas[0].PSObject.Properties['Id'] -or !$filas[0].PSObject.Properties['IpAddress'])) {
            throw 'El CSV necesita las columnas Id e IpAddress.'
        }
        $ips = @($filas | Where-Object Id -eq '4625' | ForEach-Object IpAddress)
    } else {
        $detalle = @('Fuente: registro Security de las últimas 24 h')
        $ips = @()
        try {
            $eventos = Get-WinEvent -FilterHashtable @{ LogName='Security'; Id=4625; StartTime=(Get-Date).AddHours(-24) }
            $ips = @($eventos | ForEach-Object {
                ([xml]$_.ToXml()).Event.EventData.Data | Where-Object Name -eq 'IpAddress' | ForEach-Object { $_.'#text' }
            })
        } catch {
            if ($_.FullyQualifiedErrorId -notlike 'NoMatchingEventsFound,*') { throw "Registro Security no consultable. Use -Muestra. $($_.Exception.Message)" }
        }
    }

    $grupos = @($ips | ForEach-Object {
        $ip = $null
        if ([ipaddress]::TryParse($_, [ref]$ip) -and $ip -ne [ipaddress]::Any -and $ip -ne [ipaddress]::IPv6Any) {
            if ($ip.IsIPv4MappedToIPv6) { $ip = $ip.MapToIPv4() }
            $ip.ToString()
        }
    } | Group-Object | Sort-Object -Property @{Expression='Count';Descending=$true},Name)
    $detalle += "Umbral: $Umbral", 'Fallos por IP:'
    if ($grupos.Count) { $detalle += @($grupos | ForEach-Object { "  $($_.Count) $($_.Name)" }) }
    else { $detalle += 'ninguno' }
    $alertas = @($grupos | Where-Object Count -ge $Umbral)
    $detalle += @($alertas | ForEach-Object { "Alerta para $($_.Name)" })
    [pscustomobject]@{ Alerta = ($alertas.Count -gt 0); Detalle = $detalle }
}

$secciones = 'Llavero','Puertas','Portero','Fallos'
$estados = @()
$lineas = @("Auditoría de seguridad | Windows | $(Get-Date -Format o)")
for ($i = 0; $i -lt $secciones.Count; $i++) {
    $n = $i + 1
    $seccion = $secciones[$i]
    $lineas += '', "[$n] $seccion"
    try {
        $resultado = & "Get-$seccion"
        $lineas += $resultado.Detalle
        $estado = if ($resultado.Alerta) { 'ALERTA' } else { 'OK' }
    } catch {
        $lineas += $_.Exception.Message
        $estado = 'ALERTA'
    }
    $estados += $estado
    $lineas += "→ Sección ${n}: $estado"
}
$codigo = [int]('ALERTA' -in $estados)
$veredicto = if ($codigo) { 'ALERTA' } else { 'OK' }
$resumen = for ($i = 0; $i -lt $estados.Count; $i++) { "$($i+1)=$($estados[$i])" }
$lineas += '', '[5] Veredicto', ($resumen -join ' '), "Resultado: $veredicto", "Código de salida: $codigo"
$lineas
try { $lineas | Set-Content -LiteralPath $Informe -Encoding UTF8 }
catch { Write-Error $_ -ErrorAction Continue; exit 1 }
exit $codigo
