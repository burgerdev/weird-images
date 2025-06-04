#!/bin/sh

cat /proc/$$/status | grep -e Groups -e Uid -e Gid
tail -f /dev/null
