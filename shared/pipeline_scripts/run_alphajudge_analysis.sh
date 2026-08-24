#!/bin/bash

#PBS -N alphajudge_analysis
#PBS -q default
#PBS -l select=1:ncpus=4:mem=32gb:scratch_local=60gb
#PBS -l walltime=01:30:00
#PBS -m ae

# locate the script directory (holds run specific config and other scripts) according to the runtime enviroment
if [ "$PBS_ENVIRONMENT" = "PBS_INTERACTIVE" ]; then # running inside interactive job
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ "$PBS_ENVIRONMENT" = "PBS_BATCH" ]; then # running inside batch job
    SCRIPT_DIR="${PBS_O_WORKDIR}/../scripts"
else 
    echo "Warning: Script not running inside a PBS job."
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# load config
source "${SCRIPT_DIR}/config.sh"

# activate the Alphajudge virtual enviroment 
module load mambaforge
mamba activate "$ALPHAJUDGE_VENV"

# call the analysis Python script
python "$SCRIPT_DIR/alphajudge_analysis.py"

# deactivate the enviroment
mamba deactivate 

