#!/bin/bash
set -e
set -u
set -o pipefail

ALIGNMENT=${1?Must provide an ALIGNMENT}
for XML_FILE in $(ls examples/BETS-templates/*)
do  
    GROUP_NAME="BETS/$(basename "${ALIGNMENT}" .fasta)/$(basename "${XML_FILE}" .xml)"
    pybeast \
        --run sbatch \
        --overwrite \
        --threads 8 \
        --duplicates 3 \
        --template examples/slurm.template \
        -v cpus-per-task=8 \
        --group $GROUP_NAME \
        -d "alignment=$ALIGNMENT" \
        -d "Date.delimiter=_" \
        -d "Date.dateFormat=yyyy/M/dd" \
        --ps \
        -d "ps.nrOfSteps=50" \
        -d "ps.chainLength=250000" \
        -d "ps.rootdir={{run_directory}}/logs" \
        $XML_FILE
done