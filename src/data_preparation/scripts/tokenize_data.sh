#!/usr/bin/env bash

cd /usr/data

###
# Run deduplication. This assumes that .NET Core is installed.
###

mkdir -p ./repo_tokens
python3 /usr/src/datasetbuilder/near-duplicate-code-detector/tokenizers/python/tokenizepythoncorpus.py ./raw_repos/ ./repo_tokens/
