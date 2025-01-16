#!/usr/bin/env bash

cd /usr/data

TOTAL_CPUS=$(nproc)

###
# We are now ready to run pytype on our full corpus
##
export SITE_PACKAGES=/usr/local/lib/python3.6/dist-packages
for repo in ./raw_repos/*; do
     echo Running: pytype -V3.6 -j $TOTAL_CPUS --keep-going -o ./pytype -P $SITE_PACKAGES:$repo infer $repo
     pytype -V3.6 -j $TOTAL_CPUS --keep-going -o ./pytype -P $SITE_PACKAGES:$repo infer $repo

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
