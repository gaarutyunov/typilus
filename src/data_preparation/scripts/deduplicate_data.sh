#!/usr/bin/env bash

cd /usr/data

dotnet run --no-restore --project /usr/src/datasetbuilder/near-duplicate-code-detector/DuplicateCodeDetector/DuplicateCodeDetector.csproj -- --dir="./repo_tokens/" "./corpus_duplicates"
