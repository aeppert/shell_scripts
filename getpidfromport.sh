#!/bin/sh
#
# Aaron Eppert - 2016
#
pid=$(lsof -t -P -n -i TCP:$1)
ps $pid
