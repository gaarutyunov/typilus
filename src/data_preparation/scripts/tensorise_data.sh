#!/usr/bin/env bash

add_raw_data=false
annotation_vocab_size=100
model="graph2hybridmetric"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --add-raw-data) add_raw_data=true ;;
        --annotation-vocab-size) annotation_vocab_size="$2"; shift ;;
        --model) model="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

###
# Tensorise data
##
cd /usr/src/datasetbuilder/typilus/src

python3 typilus/utils/tensorise.py /usr/data/tensorised-data/train /usr/data/graph-dataset-split/train --hypers-override "{\"cg_node_label_embedding_style\": \"Token\", \"max_type_annotation_vocab_size\": $annotation_vocab_size}" $([[ $add_raw_data == true ]] && echo "--add-raw-data") --model "$model"
python3 typilus/utils/tensorise.py /usr/data/tensorised-data/valid /usr/data/graph-dataset-split/valid --hypers-override "{\"cg_node_label_embedding_style\": \"Token\", \"max_type_annotation_vocab_size\": $annotation_vocab_size}" $([[ $add_raw_data == true ]] && echo "--add-raw-data") --metadata-to-use /usr/data/tensorised-data/train/metadata.pkl.gz --model "$model"
python3 typilus/utils/tensorise.py /usr/data/tensorised-data/test /usr/data/graph-dataset-split/test --hypers-override "{\"cg_node_label_embedding_style\": \"Token\", \"max_type_annotation_vocab_size\": $annotation_vocab_size}" $([[ $add_raw_data == true ]] && echo "--add-raw-data") --metadata-to-use /usr/data/tensorised-data/train/metadata.pkl.gz --for-test --model "$model"
