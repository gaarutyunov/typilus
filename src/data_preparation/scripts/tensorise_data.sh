#!/usr/bin/env bash

add_raw_data=false
annotation_vocab_size=10000

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --add-raw-data) add_raw_data=true ;;
        --annotation-vocab-size) annotation_vocab_size="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

cd /usr/data

readonly SRC_BASE="/usr/src/datasetbuilder/scripts/"
mkdir -p graph-dataset
python3 "$SRC_BASE"graph_generator/extract_graphs.py ./raw_repos/ ./corpus_duplicates.json ./graph-dataset $SRC_BASE/../metadata/typingRules.json --debug
mkdir -p graph-dataset-split
python3 "$SRC_BASE"utils/split.py -data-dir ./graph-dataset -out-dir ./graph-dataset-split

###
# Tensorise data
##
cd /usr/src/datasetbuilder/typilus/src

python3 typilus/utils/tensorise.py /usr/data/tensorised-data/train /usr/data/graph-dataset-split/train --hypers-override "{\"cg_node_label_embedding_style\": \"Token\", \"max_type_annotation_vocab_size\": $annotation_vocab_size}" $([[ $add_raw_data == true ]] && echo "--add-raw-data")
python3 typilus/utils/tensorise.py /usr/data/tensorised-data/valid /usr/data/graph-dataset-split/valid --hypers-override "{\"cg_node_label_embedding_style\": \"Token\", \"max_type_annotation_vocab_size\": $annotation_vocab_size}" $([[ $add_raw_data == true ]] && echo "--add-raw-data") --metadata-to-use /usr/data/tensorised-data/train/metadata.pkl.gz
python3 typilus/utils/tensorise.py /usr/data/tensorised-data/test /usr/data/graph-dataset-split/test --hypers-override "{\"cg_node_label_embedding_style\": \"Token\", \"max_type_annotation_vocab_size\": $annotation_vocab_size}" $([[ $add_raw_data == true ]] && echo "--add-raw-data") --metadata-to-use /usr/data/tensorised-data/train/metadata.pkl.gz --for-test