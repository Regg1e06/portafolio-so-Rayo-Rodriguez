
# Sistemas Operativos - Semana 1
# Diagnostico de hardware en Windows.



Write-Output "===== INFORMACION DEL CPU ====="
Get-CimInstance Win32_Processor |
    Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed |
    Format-List

Write-Output "===== MEMORIA RAM ====="
Get-CimInstance Win32_PhysicalMemory |
    Select-Object BankLabel, Capacity, Speed, Manufacturer |
    Format-Table -AutoSize

Write-Output "===== DISCOS FISICOS ====="
Get-PhysicalDisk |
    Select-Object FriendlyName, MediaType, Size, HealthStatus |
    Format-Table -AutoSize

Write-Output "===== VOLUMENES ====="
Get-Volume |
    Select-Object DriveLetter, FileSystem, Size, SizeRemaining |
    Format-Table -AutoSize

Write-Output "===== BUSES Y DISPOSITIVOS ====="
Get-PnpDevice -PresentOnly |
    Select-Object -First 30 Status, Class, FriendlyName |
    Format-Table -AutoSize

Write-Output "===== RESUMEN DEL SISTEMA ====="
systeminfo

Write-Output "===== FIN DEL DIAGNOSTICO ====="
