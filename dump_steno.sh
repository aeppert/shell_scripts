#!/bin/bash
#
# Aaron Eppert - 3/6/2019
#
# Dump a range of data from Stenographer
#
# Example: /dump_steno.sh -s "July 24 2018" -e "July 25 2018" -o /tmp -i 3600
#
USAGE="usage: dump_steno [-h] [-s <start timestamp> -e <end timestamp> -o <output directory> -i <seconds per pcap>]"

STENOREAD=/opt/stenographer/bin/stenoread

if [ "$#" -ne 8 ]; then
    echo $USAGE
    exit 1
fi

start=0
stop=0
outdir=""
interval=0

while getopts 'hs:e:o:i:' OPTION; do
  case "$OPTION" in
    h)
        echo $USAGE
        exit 1
        ;;
    s)
        start=$(date --date "$OPTARG" +%s)
        if [ $? -ne 0 ]; then
            echo "Error: start time is invalid"
            exit 1
        fi	
        ;;
    e)
        stop=$(date --date "$OPTARG" +%s)
        if [ $? -ne 0 ]; then
            echo "Error: stop time is invalid"
            exit 1
        fi	
        ;;
    o)
        outdir="$OPTARG"
        ;;
    i)
        interval=$OPTARG
        ;;
    *)
        echo $USAGE
        exit 1
        ;;
   esac
done
shift "$(($OPTIND -1))"

for t in $(seq ${start} 3600 ${stop}); do
  n=$((${t}+${interval}))
  i=$(date --date @${t} +'%Y-%m-%dT%H:%M:%SZ')
  x=$(date --date @${n} +'%Y-%m-%dT%H:%M:%SZ')
  fn=$(echo ${outdir}/${i}_${x}.pcap | sed s/\://g)
  $STENOREAD after $i and before $x -w $fn
done
