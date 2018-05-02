#! /usr/bin/env bash

# Compares two build directories looking for changes in the disassembly of the
# *.o files.

show_help() {
cat << EOF
Usage: assembly_diff.sh <BUILD1_DIR> <BUILD2_DIR>
EOF
}

if [ $# -lt 2 ]; then
    show_help
    exit 0
fi

primary_dir=$1
secondary_dir=$2

for primary_file in `find ${primary_dir} -name '*.o'`; do
    secondary_file=${secondary_dir}/${primary_file#${primary_dir}}
    if [ ! -e ${secondary_file} ]; then
        echo "WARNING: ${secondary_file} not found"
        continue
    fi

    # The first three lines need to be stripped because they contain the full
    # path name of the file:
    objdump -d ${primary_file} | tail -n +3 > /tmp/primary.txt
    objdump -d ${secondary_file} | tail -n +3 > /tmp/secondary.txt
    diff -q /tmp/primary.txt /tmp/secondary.txt > /dev/null

    if [ $? -gt 0 ]; then
        echo "WARNING: ${primary_file} and ${secondary_file} differ."
        break
    fi
done

