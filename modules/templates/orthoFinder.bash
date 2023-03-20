#!/usr/bin/env bash

set -euo pipefail

if [[ "$tarfile" == *".gz"* ]];then
    tar xzf $tarfile
else
    tar xf $tarfile
fi

mv **/* .
rm -r */

if [[ "$tarfile" == *".gz"* ]];then
    rm *.tar.gz
else
    rm *.tar
fi

for f in *; do mv "\$f" "\$f.fasta"; done

mkdir data
mv *.fasta data
orthofinder -f data -o ./results
mv results/Results*/* results
rm -rf results/Results_*
