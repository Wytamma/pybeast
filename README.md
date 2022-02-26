# pyBEAST

[![PyPi](https://img.shields.io/pypi/v/pybeast.svg)](https://pypi.org/project/pybeast/)
[![tests](https://github.com/Wytamma/pybeast/actions/workflows/test.yml/badge.svg)](https://github.com/Wytamma/pybeast/actions/workflows/test.yml)
[![cov](https://codecov.io/gh/Wytamma/pybeast/branch/master/graph/badge.svg)](https://codecov.io/gh/Wytamma/pybeast)

PyBEAST helps with running BEAST with best practices. Configure a beast run in a reproducible manner can be time consuming. pyBEAST is designed to making running beast as simple as possible. 

## Install
Install `pybeast` with pip (requires python -V >= 3.7).

```bash
pip install pybeast
```

## Command line interface

### Basic usage 

```bash
pybeast beast.xml
```

1. Create output folder and run command
2. Ensures the run is self-contained and reproducible.

```
pybeast --run bash beast.xml
```

The --run flag tells pybeast how to run the run.sh file. 

### SLURM example 

This example using the SLURM template in the examples folder to submit the beast run as a job.

```bash
pybeast --run sbatch --template examples/slurm.template examples/beast.xml
```

At a minimum the template must contain `{{BEAST}}` key. This will be replaced with the beast2 run command.

Here we use the -v (--template-variable) option to request 4 cpus. 

```bash
pybeast --run sbatch --template examples/slurm.template -v cpus-per-task=4 exmaples/beast.xml
```

Default template variables can be specified in the template in the format `{{<key>=<value>}}` e.g. {{cpus-per-task=4}}.

## dynamic variables

PyBEAST uses [dynamic-beast](https://github.com/Wytamma/dynamic-beast) to create dynamic xml files that can be modified at runtime. 

Here we use the -d (--dynamic-variable) option to set the chain length to 1000000. 

```bash
pybeast -d mcmc.chainLength=1000000 examples/beast.xml
```

The dynamic variables are saved to a `.json` file in the run directory. This file can be further edited before runtime. At run time the values in the JSON file will be used in the analysis. 

## Example 

### BETS

Use pybeast + feast to run BETS.

```bash
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
```

## Help

```
❯ pybeast --help
Usage: pybeast [OPTIONS] BEAST_XML_PATH

Arguments:
  BEAST_XML_PATH  [required]

Options:
  --run TEXT                    Run the run.sh file using this command.
  --resume / --no-resume        Resume the specified run.  [default: no-
                                resume]
  --group TEXT                  Group runs in this folder.
  --description TEXT            Text to prepend to output folder name.
  --overwrite / --no-overwrite  Overwrite run folder if exists.  [default: no-
                                overwrite]
  --seed INTEGER                Seed to use in beast analysis.
  --duplicates INTEGER          Number for duplicate runs to create.
                                [default: 1]
  -d, --dynamic-variable TEXT   Dynamic variable in the format <key>=<value>.
  --template PATH               Template for run.sh. Beast command is append
                                to end of file.
  -v, --template-variable TEXT  Template variable in the format <key>=<value>.
  --chain-length INTEGER        Number of step in MCMC chain.
  --samples INTEGER             Number of samples to collect.
  --threads INTEGER             Number of threads and beagle instances to use
                                (one beagle per core). If not specified
                                defaults to number of cores.  [default: 1]
  --mc3 / --no-mc3              Use dynamic-beast to set default options for
                                running MCMCMC.  [default: no-mc3]
  --ps / --no-ps                Use dynamic-beast to set default options for
                                running PathSampler.  [default: no-ps]
  --ns / --no-ns                Use dynamic-beast to set default options for
                                running multi threaded nested sampling.
                                [default: no-ns]
  --install-completion          Install completion for the current shell.
  --show-completion             Show completion for the current shell, to copy
                                it or customize the installation.
  --help                        Show this message and exit.
  ```