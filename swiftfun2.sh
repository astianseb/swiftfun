#!/bin/bash

# Simple shell script which copies content of given directory to Openstack Swift object storage
#
# Usage: swiftfun2.sh <contaner name> <directory>
#
# Example: swiftfun2.sh sgDD $HOME/files/
#
# Cleanup:
#
#       "for i in `swift list`; do swift delete $i;done"



_mydir=$2
_bucket_name=$1


create_s3_bucket () {
        if [ $(swift list $1 2>&1 | cut -c -9) == "Container" ]; then
                echo "Container $1 missing"
                echo "Creating $1 container"
                swift post $1 2> /dev/null
        else
                echo "Container $1 present"
        fi
}


create_s3_bucket $_bucket_name
echo $_mydir
pwd
cd $_mydir
pwd
ls
for i in `ls`;
        do
         swift upload $_bucket_name $i
        done

