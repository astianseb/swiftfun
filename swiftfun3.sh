#!/bin/bash

# Simple shell script which copies given directory into swift object storage.
# Before copying it's "codifying" directory name and files with UUID.
# Mapping of file<>UUID is stored in sqlite database
#
# Usage: swiftfun2.sh <directory>
#
# Example: swiftfun2.sh $HOME/files/
#
# Cleanup:
#
#       "for i in `swift list`; do swift delete $i;done"



_mydir=$1
DB_FILE="sg2.db"
dir_uuid=$(cat /proc/sys/kernel/random/uuid)


# Push vault to swift function
push_vault () {
        if [ ! -n "`swift list $1 2> /dev/null`" ]
                then
                        echo "Vault on swift missing"
                        echo "Pushing vault to swift "
                        cd ./Vault;
                        swift upload $1 ./$1 2> /dev/null
                else
                        echo "Vault exist!"
        fi
}


# Create database
if [ ! -e $DB_FILE ]
    then
        echo "...Database does not extist, creating one";
        sqlite3 $DB_FILE "CREATE TABLE data (id INTEGER PRIMARY KEY,dir TEXT, filename TEXT, dir_uuid TEXT, file_uuid TEXT)";
    else
        echo "...database $DB_FILE already exist!"
fi


# Populate the local  vault  with files from $_mydir
if [ -n "`sqlite3 $DB_FILE "SELECT dir FROM data WHERE dir='$_mydir'"`" ]
    then
        echo "Directory already in database!"
        exit
    else
        if [ ! -e ./Vault ];then
                mkdir ./Vault/
        fi
        mkdir ./Vault/$dir_uuid
        for i in `ls $_mydir`;do
                file_uuid=$(cat /proc/sys/kernel/random/uuid);
                sqlite3 $DB_FILE "INSERT INTO data (dir,filename,dir_uuid,file_uuid) VALUES ('$_mydir','$i','$dir_uuid','$file_uuid')";
                echo "File $i added to database $DB_FILE"
                tar -cjf ./Vault/$dir_uuid/$file_uuid.tar $_mydir/$i
        done

fi

# Push vault dir to swift
push_vault $dir_uuid
