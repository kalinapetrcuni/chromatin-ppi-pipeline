#!/bin/bash

#PBS -N fragmentation
#PBS -q default
#PBS -l select=1:ncpus=1:mem=16gb:scratch_local=30gb
#PBS -l walltime=00:30:00
#PBS -m ae

# locate the script directory (holds dataset specific config and other scripts) according to the runtime enviroment
if [ "$PBS_ENVIRONMENT" = "PBS_INTERACTIVE" ]; then # running inside interactive job
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ "$PBS_ENVIRONMENT" = "PBS_BATCH" ]; then # running inside batch job
    echo "Error: fragment_proteins.sh cannot be executed inside a batch job"
    exit 1
else 
    echo "Warning: Script not running inside a PBS job."
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# load config
source "${SCRIPT_DIR}/config.sh"

# activate the fragmentation venv
source "$ALPHAFRAGMENT_VENV/bin/activate"

# call the fragmentation Python script
python "$SCRIPT_DIR/protein_fragmentation.py" "$1"

# deactivate the venv
deactivate
