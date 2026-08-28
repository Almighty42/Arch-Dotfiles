#!/bin/sh

# 1. Compile .c file
# 2. Run .o file

cfile=$1
gcc $cfile -o 'a.o' &&
./a.o &&
rm 'a.o' &&
echo "Output file wiped, program finished successfully..."
