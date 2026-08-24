#!/bin/bash

#PBS -N download_features
#PBS -q default
#PBS -l select=1:ncpus=4:mem=16gb:scratch_local=30gb
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

# activate the fragmentation venv (to access to Python with pandas library) 
source "$ALPHAFRAGMENT_VENV/bin/activate"

# export SCRIPT_DIR to make it available to Python 
export SCRIPT_DIR="${SCRIPT_DIR}"

# call the download_features Python script
python "$SCRIPT_DIR/download_features.py"

# decompress the downloaded features
echo "Decompressing features..."
xz -d "$FEATURES_OUTPUT_DIR"/*.xz
echo "Feature decompression complete."

# deactivate the venv
deactivate
