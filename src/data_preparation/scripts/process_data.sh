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

###
# Run deduplication. This assumes that .NET Core is installed.
###

mkdir -p ./repo_tokens
python3 /usr/src/datasetbuilder/near-duplicate-code-detector/tokenizers/python/tokenizepythoncorpus.py ./raw_repos/ ./repo_tokens/
echo "In " $PWD
dotnet run --no-restore --project /usr/src/datasetbuilder/near-duplicate-code-detector/DuplicateCodeDetector/DuplicateCodeDetector.csproj -- --dir="./repo_tokens/" "./corpus_duplicates"


###
# We are now ready to run pytype on our full corpus
##
export SITE_PACKAGES=/usr/local/lib/python3.6/dist-packages
for repo in ./raw_repos/*; do
     echo Running: pytype -V3.6 --keep-going -o ./pytype -P $SITE_PACKAGES:$repo infer $repo
     pytype -V3.6 --keep-going -o ./pytype -P $SITE_PACKAGES:$repo infer $repo

     files=$(find $repo -name "*.py")
     for f in $files
     do
         f_stub=$f"i"
         f_stub="./pytype/pyi"${f_stub#"$repo"}
         if [ -f $f_stub ]; then
             echo Running: merge-pyi -i $f $f_stub
             merge-pyi -i $f $f_stub
         fi
     done
 done

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

