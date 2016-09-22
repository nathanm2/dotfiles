#!/bin/bash

usage()
{
    me=$(basename $0)
	echo "./${me} OPTIONS"
    echo "OPTIONS"
    echo -e "\t-h --help -?         : This usage statement."
    echo -e "\t-i --input DIR       : The root of the source directory."
    echo -e "\t-o --output DIR      : Where to put the cscope files."
}

input="${PWD}"
output="${PWD}/cscope_files"

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -h|--help)
            usage
            exit 0
            ;;
        -i|--input)
            input="$2"
            shift
            ;;
        -o|--output)
            output="$2"
            shift
            ;;
    esac
    shift
done
