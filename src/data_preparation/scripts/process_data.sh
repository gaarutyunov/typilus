#!/usr/bin/env bash

/usr/src/datasetbuilder/scripts/tokenize_data.sh "$@"
/usr/src/datasetbuilder/scripts/deduplicate_data.sh "$@"
if [[ " $* " == *" --pytype "* ]]; then
/usr/src/datasetbuilder/scripts/pytype_data.sh "$@"
fi
/usr/src/datasetbuilder/scripts/extract_graphs.sh "$@"
/usr/src/datasetbuilder/scripts/split_data.sh "$@"
/usr/src/datasetbuilder/scripts/tensorise_data.sh "$@"
