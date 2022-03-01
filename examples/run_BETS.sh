#!/bin/bash
set -e
set -u
set -o pipefail

ALIGNMENT=${1?Must provide an ALIGNMENT.fasta file}
for XML_FILE in $(ls examples/BETS-templates/*)
do  
    GROUP_NAME="examples/$(basename "${ALIGNMENT}" .fasta)-BETS/$(basename "${XML_FILE}" .xml)"
    pybeast \
        --run sbatch \
        --group $GROUP_NAME \
        --duplicates 3 \
        --template examples/slurm.template \
        -v cpus-per-task=2 \
        --ns \
        -d "alignment=$ALIGNMENT" \
        -d "Date.delimiter=_" \
        -d "Date.dateFormat=yyyy/M/dd" \
        -d "Date.everythingAfterLast=true" \
        -d "mcmc.particleCount=32" \
        $XML_FILE
done