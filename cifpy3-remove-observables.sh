#!/bin/sh

if [$# -ne 1]; then
    echo "usage: cifpy3-remove-observables.sh <observable>"
    exit 1
fi

for i in `curl 'localhost:9200/_cat/indices?v' | awk '{print $3}' | grep cif\.observable`; do
    curl -XDELETE http://localhost:9200/$i/observables/_query -d "
    {
      "query": { "match": { "observable": \"$1\" } }
    }"
done
