#!/bin/bash

# A simple script for creating cscope cross reference files.
#
me=$(basename $0)

usage()
{
	echo "./${me} OPTIONS"
    echo "OPTIONS"
    echo -e "\t-h --help            : This usage statement."
}

usage
exit 0

mkdir -p ${dir}
find ${PWD} -name "*.[CcHh]" -o -name "*.cpp" -o -name "*.cc" -o -name "*.hpp" > ${dir}/cscope.files
$(cd ${dir}; cscope -b -q)

