#!/bin/bash

arg=$@
src=""
dest=""
file_type=""
helpp="./Backup.sh -s <source directory> -d <destination> -f <files extention>"
error="wrong usage please check -h or --help flags to see correct usage"

msg()
{
    echo $1
}

while test "$1x" != "x"
do
    case $1
    in
        -s|--source) src=$2;shift ;;
        -d|--destination) dest=$2;shift ;;
        -f|--file) file_type=$2;shift ;;
        -h|--help) msg $helpp;break ;;
         *) msg $error;break ;;
    esac
    shift
done

cd $src
cp *$file_type $dest

exit 0