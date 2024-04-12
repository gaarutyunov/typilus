#!/usr/bin/env bash

if [ -z "$1" ]
then
     echo "No argument supplied"
     exit 1
fi

if ! [ -f "$1" ]
then
     echo "File doesn't exist"
     exit 1
fi

# Get the input's absolute path
d=$(dirname "$1")
input="$(cd "$d"; pwd -P)/$(basename "$1")"
echo "Reading a project list from $input"

mkdir -p /usr/data/raw_repos
cd /usr/data/raw_repos

# To clone a dataset based on a .spec file:
#   * Comment the lines below that clone the dataset and create the .spec
#   * Replace with:
bash /usr/src/datasetbuilder/scripts/clone_from_spec.sh $input
