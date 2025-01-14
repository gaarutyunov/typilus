#!/usr/bin/env bash

cd /usr/data

readonly SRC_BASE="/usr/src/datasetbuilder/scripts/"
mkdir -p graph-dataset
python3 "$SRC_BASE"graph_generator/extract_graphs.py ./raw_repos/ ./corpus_duplicates.json ./graph-dataset $SRC_BASE/../metadata/typingRules.json --debug
