#!/bin/bash

# A simple script for creating cscope cross reference files.
#


usage()
{
    me=$(basename $0)
	echo "./${me} OPTIONS"
    echo "OPTIONS"
    echo -e "\t-h --help -?         : This usage statement."
    echo -e "\t-i --input DIR       : The root of the source directory."
    echo -e "\t-o --output DIR      : Where to put the cscope files."
    echo -e "\t-f --find-args STR   : The search paramaters to find."
    echo -e "\t-c --cscope-args STR : The cscope arguments."
}

input="${PWD}"
output="${PWD}/cscope_files"
find_args='-name "*.[CcHh]" -o -name "*.cpp" -o -name "*.cc" -o -name "*.hpp"'
cscope_args='-b -q'

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
        -f|--find-args)
            find_args="$2"
            shift
            ;;
        -c|--cscope-args)
            cscope_args="$2"
            shift
            ;;
    esac
    shift
done


mkdir -p ${output}
eval find ${input} ${find_args} > ${output}/cscope.files
eval $(cd ${output}; cscope ${cscope_args} )

