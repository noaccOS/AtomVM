#!/bin/bash

set -e

ROOT_DIR=$(cd $(dirname $0)/../.. && pwd)

function clean_file {
    file=$1
    cat ${file} | sed "s/[ ]*$//g" | sed -e '$a\' > ${file}.cleaned
    if [ -n "$(diff ${file} ${file}.cleaned)" ]; then
        cat ${file}.cleaned > ${file}
        echo "Cleaned ${file}"
    fi
    rm ${file}.cleaned
}

nargs=$#
if [ "${nargs}" -gt 0 ]; then
    files=$@
else
    files=$(git ls-files)
fi

cd ${ROOT_DIR}
for f in ${files}; do
    case $f in
        *.sh | *.erl | *.c | *.h | *.txt)
            clean_file $f
            ;;
    esac
done

