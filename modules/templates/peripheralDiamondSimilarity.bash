#!/usr/bin/env bash

set -euo pipefail

diamond blastp \
  -d $database \
  -q $fasta \
  -o ${fasta}.out \
  -f 6 $outputList \
  --comp-based-stats 0

sort -k 2 ${fasta}.out > diamondSimilarity.tmp
mv diamondSimilarity.tmp ${fasta}.out



