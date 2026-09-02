#!/bin/bash

#PBS -N create_features
#PBS -q default
#PBS -l select=1:ncpus=8:mem=60gb:scratch_local=3200gb
#PBS -l walltime=48:00:00
#PBS -m ae

# check if the script is running inside of a job
if [[ -z "$PBS_O_WORKDIR" ]]; then
echo "Error: Variable PBS_O_WORKDIR contains no path. Script is likely not running inside an OpenPBS batch job."
exit 1
fi

# locate and load config
SCRIPT_DIR="${PBS_O_WORKDIR}/../scripts"
source "${SCRIPT_DIR}/config.sh"

# assign paths to resources from config-sourced variables
MY_OUTPUT_DIR="$FEATURES_OUTPUT_DIR"
INPUT_FASTA="$FRAGMENTATION_OUTPUT_DIR"/alphapulldown-sequences.fasta

# TODO: temporary debug prints
echo "Features output: $MY_OUTPUT_DIR"
echo "Input fasta: $INPUT_FASTA"

# database fragments
bfd="/storage/projects/Bio_databases/AlphaPulldown/2.1.9/AF2_db/bfd"
mgnify="/storage/projects/Bio_databases/AlphaPulldown/2.1.9/AF2_db/mgnify"  
params="/storage/projects/Bio_databases/AlphaPulldown/2.1.9/AF2_db/params"  
pdb70="/storage/projects/Bio_databases/AlphaPulldown/2.1.9/AF2_db/pdb70"  
pdb_seqres="/storage/projects/Bio_databases/AlphaPulldown/2.1.9/AF2_db/pdb_seqres"  
small_bfd="/storage/projects/Bio_databases/AlphaPulldown/2.1.9/AF2_db/small_bfd"  
uniprot="/storage/projects/Bio_databases/AlphaPulldown/2.1.9/AF2_db/uniprot"  
uniref30="/storage/projects/Bio_databases/AlphaPulldown/2.1.9/AF2_db/uniref30"  
uniref90="/storage/projects/Bio_databases/AlphaPulldown/2.1.9/AF2_db/uniref90"


# define copying function
copy_to_scratch(){
    local target_dir="$SCRATCHDIR"/my_ap_db/
    echo "Copying $1"
    cp -r "$1" "$target_dir/$(basename "$f")" 
}


echo "Starting database copy at time: $(date +%s)"
START_TIME=$(date +%s)

# create database location in SCRATCH
mkdir "$SCRATCHDIR"/my_ap_db   

# copy each DB fragment
for f in "$bfd" "$mgnify" "$params" "$pdb70" "$pdb_seqres" "$small_bfd" "$uniprot" "$uniref30" "$uniref90"; do
    copy_to_scratch $f
done

# symlink pdb_mmcif (because we won't be copying it)
ln -s "/storage/projects/Bio_databases/AlphaPulldown/2.1.9/AF2_db/pdb_mmcif" "$SCRATCHDIR"/my_ap_db/pdb_mmcif 

COPY_END_TIME=$(date +%s)
echo "DATABASE COPY FINISHED at time: $(date +%s), it took: $(($COPY_END_TIME - $START_TIME)) s"



# create output directory in SCRATCH
mkdir "$SCRATCHDIR"/scratch_output

# create and set TMP directory for Python inside Singularity to a dir in SCRATCH
mkdir "$SCRATCHDIR"/my_tmp
export SINGULARITYENV_TMPDIR="$SCRATCHDIR"/my_tmp


echo "Starting Alphapulldown create_features.py"

singularity exec /cvmfs/singularity.metacentrum.cz/AlphaPullDown/af2pulldown.2.1.9.sif create_individual_features.py \
        --fasta_paths="$INPUT_FASTA" \
        --data_dir="$SCRATCHDIR/my_ap_db" \
        --output_dir="$SCRATCHDIR/scratch_output" \
        --max_template_date=2025-04-10 \

CREATE_FEATURES_END_TIME=$(date +%s)
echo "Alphapulldown create_features.py FINISHED at time: $(date +%s), it took: $(($CREATE_FEATURES_END_TIME - $COPY_END_TIME)) s with the input: $INPUT_FASTA"


# copy output from scratch
cp -r "$SCRATCHDIR"/scratch_output/* "$MY_OUTPUT_DIR"/

clean_scratch

