#!bin/bash

filename="feat1.txt"

sed -z -i 's/\n/,/g' $filename

filename="feat2.txt"

sed -z -i 's/\n/,/g' $filename

filename="feat3.txt"

sed -z -i 's/\n/,/g' $filename

read -p "Press any key to continue... " -n1 -s