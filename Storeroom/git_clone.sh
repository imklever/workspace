#!/bin/bash

function usage()
{
    echo -e "\033[31musage: $0 <dir> <gitlist file>\033[0m"
}

if [ 2 -ne $# ];then
    usage
    exit 0
fi

git_dir=$1
git_list_file=$2

while read line
do
    echo "No----------------"
    url=`echo $line | awk '{print $NF}'`
    echo $url
    cd $git_dir
    git clone $url
    cd -
done < $git_list_file
