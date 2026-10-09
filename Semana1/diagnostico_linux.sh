
#!/bin/bash

# Sistemas Operativos - Semana 1
# Diagnostico de hardware en Linux.
echo "===== INFORMACION DEL CPU ====="
lscpu
cat /proc/cpuinfo

echo "===== MEMORIA RAM ====="
free -h
cat /proc/meminfo

echo "===== ALMACENAMIENTO ====="
lsblk
df -h

echo "===== BUSES Y DISPOSITIVOS ====="
lspci
lsusb

echo "===== RESUMEN DEL HARDWARE ====="
sudo lshw -short

echo "===== FIN DEL DIAGNOSTICO ====="
