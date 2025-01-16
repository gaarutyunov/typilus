#!/usr/bin/env bash

cd /usr/data

cpuset=$(cat /sys/fs/cgroup/cpuset/cpuset.cpus)
limits=(${cpuset//-/ })
TOTAL_CPUS=$((${limits[1]}-${limits[0]}+1))
echo "CPU count is ${TOTAL_CPUS}"

###
# We are now ready to run pytype on our full corpus
##
export SITE_PACKAGES=/usr/local/lib/python3.6/dist-packages
for repo in ./raw_repos/*; do
     echo Running: pytype -V3.9 -j $TOTAL_CPUS --keep-going -o ./pytype -P $SITE_PACKAGES:$repo infer $repo
     pytype -V3.9 -j $TOTAL_CPUS --keep-going -o ./pytype -P $SITE_PACKAGES:$repo infer $repo

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
