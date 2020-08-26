#!/bin/sh -e
SPATH=/usr/local/bin/sbash

echo '#!/usr/bin/bash
/bin/tty -s
if [ $? -eq 0 ]; then
  export LD_PRELOAD=/usr/lib64/libsnoopy.so
fi
exec /usr/bin/bash "$@"' > "$SPATH"

chmod 0775 "$SPATH"

(echo "$SPATH" ; cat /etc/shells) | sort | uniq > /etc/sbash_shells
chmod --reference=/etc/shells  /etc/sbash_shells
chown --reference=/etc/shells  /etc/sbash_shells
mv /etc/sbash_shells /etc/shells
