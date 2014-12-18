#!/bin/bash

file1="aaa"
file2="runSuite.sh"

strings=`cat aaa|awk -F: '{print $1}'`

for string in $strings;do
    lineNo=`sed -n "/$string/=" $file2`
    echo"###### lineNo : $lineNo, Cases : $string"
    sed -i -e "$lineNo s/^/#/g" $file2
done

