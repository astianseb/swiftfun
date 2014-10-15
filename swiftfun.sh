#!/bin/bash

# Simple shell script which generates random files in ../files/ directory
# and copies them to Openstack Swift object storage
#
# Usage: swiftfun.sh <swift container name>
#
# Example: swiftfun.sh sgAA
#
# Cleanup:
#
#       "for i in `swift list`; do swift delete $i;done"
#       "rm -rf ./files/



_mydir=$(pwd)
_bucket_name=$1


createfiles () {
        if [ ! -d "$_mydir/files" ];then
                echo "Creting seed files..."
                mkdir $_mydir/files
                cd files
                for i in {1..5}
                 do
                  dd if=/dev/urandom of=file$i.txt bs=2048 count=10
                 done
        else
                echo "Directory exist!"
        fi
}


create_s3_bucket () {
        if [ $(swift list $1 2>&1 | cut -c -9) == "Container" ]; then
                echo "Container $1 missing"
                echo "Creating $1 container"
                swift post $1 2> /dev/null
        else
                echo "Container $1 present"
        fi
}


createfiles
wait 10
echo "...waiting to create files"
create_s3_bucket $_bucket_name

cd $_mydir/files
for i in `ls`;
        do
         swift upload $_bucket_name $i
        done


