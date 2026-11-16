# Ayuda memoria de comandos

Sistemas Operativos GR1 · Semana 5 · Miguel Rayo e Italo Rodríguez

| Consulta | AlmaLinux | Windows PowerShell |
| --- | --- | --- |
| Identidad de la sesión | `id` | `whoami /user` |
| Grupos e integridad | `id` y `getent group wheel` | `whoami /groups` |
| Cuentas privilegiadas | `awk -F: '$3==0{print $1}' /etc/passwd` | `Get-LocalGroupMember -SID 'S-1-5-32-544'` |
| Privilegios de la sesión | `sudo -l` | `whoami /priv` |
| Sockets TCP en escucha | `ss -H -tln` | `Get-NetTCPConnection -State Listen` |
| Proceso detrás del puerto | `sudo ss -tlnp` | `Get-Process -Id (Get-NetTCPConnection -State Listen -LocalPort 135)[0].OwningProcess` |
| Estado del cortafuegos | `systemctl is-active firewalld` | `Get-NetFirewallProfile` |
| Zonas, servicios y reglas | `firewall-cmd --get-active-zones` y `firewall-cmd --list-all` | `Get-NetFirewallRule -Enabled True -Direction Inbound` |
| Servicios del cortafuegos | `systemctl status firewalld` | `Get-Service mpssvc,BFE` |
| Motor de filtrado (admin) | `sudo nft list ruleset` | `netsh wfp show filters` |
| Bitácora de privilegios | `journalctl -t sudo -n 3 --no-pager` | `Get-WinEvent -FilterHashtable @{LogName='Security';Id=4672} -MaxEvents 5` |
| Fallos de autenticación | `journalctl -u sshd --since '24 hours ago'` | `Get-WinEvent -FilterHashtable @{LogName='Security';Id=4625} -MaxEvents 5` |

## DROP y REJECT

`curl -s -o /dev/null -m 5 -w '%{time_total}\\n' http://127.0.0.1:8080` mide el tiempo. Guarda `$?` inmediatamente. En nuestra práctica, DROP agotó el tiempo (28) y REJECT con TCP reset terminó de inmediato (7). El servidor local respondió HTTP 200 antes de agregar reglas.

## Fallos por IP con umbral 3

```bash
awk '/Failed password/{for(i=1;i<NF;i++)if($i=="from"){print $(i+1);break}}' muestras/muestra_sesion3_auth.log | sort | uniq -c | awk '$1>=3'
```

```powershell
Import-Csv .\muestras\muestra_sesion3_4625.csv | Where-Object Id -eq 4625 |
    Group-Object IpAddress | Where-Object Count -ge 3
```

## Códigos de salida

En Bash, `$?` conserva el estado del último comando. En PowerShell, mira `$LASTEXITCODE` al terminar el script. El Deber 5 usa **0** para OK y **1** cuando al menos una sección queda en ALERTA.
