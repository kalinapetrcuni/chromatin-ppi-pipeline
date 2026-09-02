#!/bin/bash

#PBS -N run_multimer_jobs
#PBS -q default
#PBS -l select=1:ncpus=4:mem=64gb:ngpus=1:scratch_local=500gb:gpu_cap=compute_70
#PBS -l walltime=40:00:00
#PBS -m ae

# check if the script is running inside of a batch job
if [[ -z "$PBS_O_WORKDIR" ]]; then
echo "Error: Variable PBS_O_WORKDIR contains no path. Scripts is likely not run inside an OpenPBS batch job."
exit 1
fi

# locate and load config
SCRIPT_DIR="${PBS_O_WORKDIR}/../scripts"
source "${SCRIPT_DIR}/config.sh"

# load paths to resources from config-sourced variables
MY_OUTPUT_DIR="$MULTIMER_OUTPUT_DIR"
PROTEIN_LIST="$FRAGMENTATION_OUTPUT_DIR"/alphapulldown-protein-list.txt # defines protein combinations for predictions
monomer_objects_dir="$FEATURES_OUTPUT_DIR" # pickle files from previous step

params="/storage/projects/Bio_databases/AlphaPulldown/2.1.9/AF2_db/params"

# TODO: temporary prints
echo "Multimer output: $MY_OUTPUT_DIR"
echo "Protein list: $PROTEIN_LIST"
echo "Pickle file source: $monomer_objects_dir"


echo "Starting params copy at time: $(date +%s)"
START_TIME=$(date +%s)

# # create database location in SCRATCH
mkdir "$SCRATCHDIR"/my_ap_db
cp -r "$params" "$SCRATCHDIR"/my_ap_db/params

COPY_END_TIME=$(date +%s)
echo "params COPY FINISHED at time: $(date +%s), it took: $(($COPY_END_TIME - $START_TIME)) s"


# copy inputs 
cp -r "$monomer_objects_dir" "$SCRATCHDIR"/scratch_input


# create output directory in SCRATCH
mkdir "$SCRATCHDIR"/scratch_output

# create and set TMP directory inside Singularity to a dir in SCRATCH
mkdir "$SCRATCHDIR"/my_tmp
export SINGULARITYENV_TMPDIR="$SCRATCHDIR"/my_tmp

echo "Starting Alphapulldown run_multimer_jobs.py"

singularity exec --nv /cvmfs/singularity.metacentrum.cz/AlphaPullDown/af2pulldown.2.1.9.sif run_multimer_jobs.py \
  --mode=custom \
  --monomer_objects_dir="$SCRATCHDIR"/scratch_input \
  --data_dir="$SCRATCHDIR"/my_ap_db\
  --protein_lists="$PROTEIN_LIST"\
  --output_path="$SCRATCHDIR"/scratch_output \
  --num_cycle=3 \
  --num_predictions_per_model=1

RUN_MULTIMER_JOBS_END_TIME=$(date +%s)
echo "run_multimer_jobs.py finished at time: $(date +%s), it took: $(($RUN_MULTIMER_JOBS_END_TIME - $COPY_END_TIME)) s"

# copy output from scratch
cp -r "$SCRATCHDIR"/scratch_output/* "$MY_OUTPUT_DIR"/ 

clean_scratch

