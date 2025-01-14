#!/usr/bin/env bash

cd /usr/data

readonly SRC_BASE="/usr/src/datasetbuilder/scripts/"
mkdir -p graph-dataset-split
python3 "$SRC_BASE"utils/split.py -data-dir ./graph-dataset -out-dir ./graph-dataset-split