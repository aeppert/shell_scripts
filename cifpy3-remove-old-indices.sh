#!/bin/bash
#
# Aaron Eppert - 2016
#
# Delete cifpy3 format indices from elasticsearch maintaining only a
# specified number based on days
#
#   Inspiration:
#     https://github.com/imperialwicket/elasticsearch-logstash-index-mgmt/blob/master/elasticsearch-remove-old-indices.sh
#
# Must have access to the specified elasticsearch node.

usage()
{
cat << EOF

cifpy3-remove-old-indices.sh

Compares the current list of indices to a configured value and deletes any
indices surpassing the number of days.

USAGE: ./cifpy3-remove-old-indices.sh [OPTIONS]

OPTIONS:
  -h    Show this message
  -i    Indices to keep in days (default: 31)
  -e    Elasticsearch URL (default: http://localhost:9200)
  -o    Output actions to a specified file

EXAMPLES:

  ./cifpy3-remove-old-indices.sh

    Connect to http://localhost:9200 and get a list of indices matching
    'logstash'. Keep the top lexicographical 14 indices, delete any others.

  ./cifpy3-remove-old-indices.sh -e "http://my.cifpy3.server.com:9200" \
  -i 28 -o /mnt/es/logfile.log

    Connect to http://my.cifpy3.server.com:9200 and get a list of indices matching
    'my-logs'. Keep the last 28 days of indices, delete any others.
    Output index deletes to /mnt/es/logfile.log.

EOF
}

# Defaults
ELASTICSEARCH="http://localhost:9200"
KEEP_DAYS=31
GREP="cif.observables"

# Validate numeric values
RE_D="^[0-9]+$"

while getopts ":i:e:o:h" flag
do
  case "$flag" in
    h)
      usage
      exit 0
      ;;
    i)
      if [[ $OPTARG =~ $RE_D ]]; then
        KEEP=$OPTARG
      else
        ERROR="${ERROR}Days to keep must be an integer.\n"
      fi
      ;;
    e)
      ELASTICSEARCH=$OPTARG
      ;;
    o)
      LOGFILE=$OPTARG
      ;;
    ?)
      usage
      exit 1
      ;;
  esac
done

# If we have errors, show the errors with usage data and exit.
if [ -n "$ERROR" ]; then
  echo -e $ERROR
  usage
  exit 1
fi

# Get the indices from elasticsearch
INDICES_TEXT=`curl -s "$ELASTICSEARCH/_cat/indices?v" | awk '/'$GREP'/{match($0, /[:blank]*('$GREP'.[^ ]+)[:blank]*/, m); print m[1];}' | sort -r`

DATE_NOW=$(date +%Y-%m-%d)

datediff_in_days() {
    d1=$(date -d "$1" +%s)
    d2=$(date -d "$2" +%s)
    echo $(( (d1 - d2) / 86400 ))
}

index_to_date() {
    echo $1 | awk -F'-' {'print $2'} | sed 's/\./\-/g'
}

if [ -z "$INDICES_TEXT" ]; then
  echo "No indices returned containing '$GREP' from $ELASTICSEARCH."
  exit 1
fi

# If we are logging, make sure we have a logfile TODO - handle errors here
if [ -n "$LOGFILE" ] && ! [ -e $LOGFILE ]; then
  touch $LOGFILE
fi

# Delete indices
for index in $INDICES_TEXT; do
    t_diff=$(datediff_in_days $DATE_NOW $(index_to_date $index))

    if [ $t_diff -gt $KEEP_DAYS ]; then
        if [ -n "$index" ]; then
            t_log="/dev/null"

            if [ ! -z "$LOGFILE" ]; then
                t_log=$LOGFILE
                echo `date "+[%Y-%m-%d %H:%M] "`" Deleting index: $index." >> $LOGFILE
            fi

            curl -s -XDELETE "$ELASTICSEARCH/$index/" >> $t_log
            echo >>$t_log
        fi
    fi
done

exit 0
