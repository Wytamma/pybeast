#!/bin/bash
set -e
set -u
set -o pipefail

ALIGNMENT=${1?Must provide an ALIGNMENT}
for XML_FILE in $(ls examples/BETS-templates/*)
do  
    GROUP_NAME="BETS/$(basename "${ALIGNMENT}" .fasta)/$(basename "${XML_FILE}" .xml)"
    pybeast \
        --overwrite \
        --duplicates 1 \
        --template examples/slurm.template \
        -v cpus-per-task=8 \
        --group $GROUP_NAME \
        -d "alignment=$ALIGNMENT" \
        -d "Date.delimiter=_" \
        -d "Date.dateFormat=yyyy/M/dd" \
        --ns \
        -d "mcmc.particleCount=1" \
        -d "mcmc.threads=1" \
        $XML_FILE
done