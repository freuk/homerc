#!/usr/bin/env bash

set -eE
trap 'notify-send -u cricital "Mail sync failed."'

function func() {
  BEFORE=$( NOTMUCH_CONFIG=/run/user/1000/secrets/notmuch notmuch count \
    "tag:inbox and ((not tag:spam and not tag:archivedlist) or tag:high) and (not tag:sent)" \
  )

  /nix/store/krapwq1nw0nxsy0bdx8zqrn61b915r7p-isync-1.3.1/bin/mbsync -a -c /run/user/1000/secrets/mbsync

  NOTMUCH_CONFIG=/run/user/1000/secrets/notmuch \
    /nix/store/cvkx9whvzg0bj76b685z6dp1szyf99vs-notmuch-0.29.3/bin/notmuch new

  NOTMUCH_CONFIG=/run/user/1000/secrets/notmuch \
  XDG_CONFIG_HOME=/run/user/1000/secrets/afew \
    /nix/store/957kjdqsfsfh2xa3vb7wm0jj4iddqf74-afew-2.0.0/bin/afew -t -n

  AFTER=$(NOTMUCH_CONFIG=/run/user/1000/secrets/notmuch notmuch count \
    "tag:inbox and ((not tag:spam and not tag:archivedlist) or tag:high) and (not tag:sent)" \
  )

  echo $AFTER
  echo $BEFORE
  DIFFERENCE=$((AFTER-BEFORE))
  echo $DIFFERENCE
  export DISPLAY=":0"

  if [[ $DIFFERENCE -gt 0 ]]
  then
    notify-send -u normal "New mail: $(DIFFERENCE) new message(s) passed spam filter."
  else
    notify-send -u low "No new mail."
  fi
}
func
