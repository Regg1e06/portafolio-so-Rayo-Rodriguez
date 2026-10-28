# Autores: Miguel Rayo, Italo Rodriguez | 2026-10-27
# IA: ChatGPT/Codex para organizar comandos y depurar la medición.
$ErrorActionPreference='Stop'
function Paso($titulo,[scriptblock]$accion) {
    "`n=== $titulo ==="
    try { & $accion | Out-String -Width 200 } catch { "AVISO: $($_.Exception.Message)" }
}
function Medir($programa,$argumentos) {
    $temporal=Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
    try {
        $p=Start-Process -FilePath $programa -ArgumentList $argumentos -PassThru -WindowStyle Hidden -RedirectStandardOutput $temporal
        $null=$p.Handle
        $p.WaitForExit(); $p.Refresh()
        $real=($p.ExitTime-$p.StartTime).TotalSeconds
        $cpu=$p.TotalProcessorTime.TotalSeconds
        "Programa: $programa $argumentos | Código de salida: $($p.ExitCode)"
        if($real -gt 0){
            $espera=1-$cpu/$real
            'real={0:F6} s; CPU={1:F6} s; p={2:F3}' -f $real,$cpu,$espera
            if($espera -gt 0 -and $espera -lt 1){
                "n para U>=90% en el modelo: $([math]::Ceiling([math]::Log(0.1)/[math]::Log($espera)))"
            } else { 'p fuera del intervalo (0,1): revisar resolución, concurrencia y sobrecarga de medición.' }
        }
    } finally { if(Test-Path -LiteralPath $temporal){Remove-Item -LiteralPath $temporal} }
}
"TALLERES WINDOWS | $(Get-Date -Format o) | $env:COMPUTERNAME"
Paso 'W1 · Procesos' {
    "Total: $(@(Get-Process).Count)"; Get-Process -Id 4
    Get-CimInstance Win32_Processor | Select-Object NumberOfLogicalProcessors
}
Paso 'W2 · Servicios' {
    $s=@(Get-Service | Where-Object Status -eq Running)
    "En ejecución: $($s.Count)"; $s | Select-Object -First 8
}
Paso 'W3 · Memoria (KiB) y discos (bytes)' {
    Get-CimInstance Win32_OperatingSystem | Select-Object TotalVisibleMemorySize,FreePhysicalMemory | Format-List
    Get-CimInstance Win32_LogicalDisk | Select-Object DeviceID,Size,FreeSpace | Format-Table -AutoSize
}
Paso 'W4 · CIM/WMI' {Get-CimInstance Win32_OperatingSystem | Select-Object Caption,Version,LastBootUpTime}
Paso 'W5 · CPU ociosa' {Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor -Filter "Name='_Total'" | Select-Object PercentIdleTime}
Paso 'B · Espera de red' {Medir "$env:SystemRoot\System32\PING.EXE" '-n 3 127.0.0.1'}
Paso 'B · Cálculo' {Medir "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" ('-NoProfile -ExecutionPolicy Bypass -File "{0}"' -f (Join-Path $PSScriptRoot 'clases\carga_cpu.ps1'))}
Paso 'B · Lectura del disco' {Medir "$env:SystemRoot\System32\cmd.exe" '/c dir C:\Windows\System32 /s'}
'p es una estimación de tiempo fuera de CPU; incluye planificación y sobrecarga. No demuestra por sí solo espera física del disco.'
'Las consultas de arranque, drivers e inicio rápido se guardan en informe_arranque.ps1.'
'Prueba de programar/cancelar reinicio: PENDIENTE MANUAL. No se ejecuta en este archivo.'

