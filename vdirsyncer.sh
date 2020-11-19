#!/usr/bin/env bash

vdirsyncer sync

if [[ $? -gt 0 ]]
then
  notify-send -u critical "Caldav Sync FAILURE."
else
  notify-send "Synchronized CalDAV"
fi
