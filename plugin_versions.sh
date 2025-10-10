#! /bin/bash

paper_ver=$(ps aux | grep [j]ava | grep -Eo 'paper.*jar')

echo "Paper Version: $paper_ver"
echo
echo "Plugin            Version"
echo "====================================="
ls -1 ~/paper_minecraft/plugins/*.jar | rev | cut -d'/' -f1 | rev | sed -E 's/(.+)-([0-9][0-9.].*)\.jar/\1\t\2/' | column -s $'\t' -t
