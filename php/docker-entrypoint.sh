#!/usr/bin/env bash

set -e

#############################################################################################################
if [[ -f ${PWD}/manacli ]] && [[ ! -e /usr/share/bash-completion/completions/manacli ]]; then
    cat << EOF > /usr/share/bash-completion/completions/manacli
#!/bin/bash

_manacli(){
   COMPREPLY=( \$(php ${PWD}/manacli.php bash_completion complete \$COMP_CWORD "\${COMP_WORDS[@]}") )
   return 0;
}

complete -F _manacli manacli
EOF
    chmod a+x /usr/share/bash-completion/completions/manacli ${PWD}/manacli
    dos2unix -q ${PWD}/manacli
    ln -s ${PWD}/manacli /bin/manacli
fi

###############################################################################################
if [ "$PHPFPM_LISTEN" != '' ]; then
  sed -i "s|^listen =.*|listen = $PHPFPM_LISTEN|" /etc/php/fpm/pool.d/www.conf
fi

rm -rf /etc/cron.d
if [ -d /tmp/cron.d ] && [ "$APP_CRON_ENABLED" != '0' ]; then
  cp -r /tmp/cron.d /etc/cron.d

  chmod -R 0644 /etc/cron.d &&chown -R root:root /etc/cron.d
  for file in /etc/cron.d/*; do
    dos2unix -q $file
    mac2unix -q $file
    echo '' >>$file
  done

  syslogd -O /var/log/cron.log && cron -L 15
fi

if [ $# == 0 ]; then
  if [ -d /etc/cron.d ]; then
    exec tail -f -n 1 /var/log/cron.log
  else
    exec tail -f /dev/null
  fi
else
  exec "$@"
fi