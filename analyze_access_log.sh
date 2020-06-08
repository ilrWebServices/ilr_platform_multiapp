#!/bin/zsh
{ while true; do rsync -az `platform ssh --app=proxy --environment=master --pipe`:/var/log/access.log ./; sleep 5; done } &
{ goaccess ./access.log -c --num-test=0; }
wait -n
pkill -P $$
echo done
