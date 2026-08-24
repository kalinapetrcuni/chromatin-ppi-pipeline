#!/bin/bash

set -euo pipefail

# Configuration
SCRIPT_SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# load global config
source "${SCRIPT_SOURCE_DIR}/global_config.sh"

# Parse arguments
DATASET=""
INPUT_CSV=""

while [[ $# -gt 0 ]]; do
case "$1" in
--dataset-name)
DATASET="$2"
shift 2
;;
--input-csv)
INPUT_CSV="$2"
shift 2
;;
-h|--help)
cat <<EOF
Usage:
$0 --dataset-name DATASET_NAME --input-csv PATH_TO_INPUT_CSV
EOF
exit 0
;;
*)
echo "Unknown argument: $1"
exit 1
;;
esac
done

########################################
# Validate inputs
########################################

if [[ -z "$DATASET" ]]; then
echo "Error: --dataset is required"
exit 1
fi

if [[ -z "$INPUT_CSV" ]]; then
echo "Error: --input-csv is required"
exit 1
fi

if [[ ! -f "$INPUT_CSV" ]]; then
echo "Error: input CSV not found: $INPUT_CSV"
exit 1
fi

########################################
# Create directory structure
########################################

BASE_DIR="${PWD}/${DATASET}_dataset"

mkdir -p \
"${BASE_DIR}/features_output_dir" \
"${BASE_DIR}/fragmentation_output_dir" \
"${BASE_DIR}/fragmentation_output_dir/fragmentation_figures" \
"${BASE_DIR}/job_work_dir" \
"${BASE_DIR}/multimer_output_dir" \
"${BASE_DIR}/results" \
"${BASE_DIR}/scripts"

########################################
# Copy input CSV
########################################

cp "$INPUT_CSV" "${BASE_DIR}/input.csv"

########################################
# Generate paths
########################################

CSV_FILE="${BASE_DIR}/input.csv"
FEATURES_DIR="${BASE_DIR}/features_output_dir"
FRAGMENTATION_DIR="${BASE_DIR}/fragmentation_output_dir"
MULTIMER_DIR="${BASE_DIR}/multimer_output_dir"


########################################
# Generate config.sh
########################################

cat > "${BASE_DIR}/scripts/config.sh" <<EOF
#!/usr/bin/bash

export DATASET="${DATASET}"

export INPUT_CSV="${CSV_FILE}"
export FEATURES_OUTPUT_DIR="${FEATURES_DIR}"
export FRAGMENTATION_OUTPUT_DIR="${FRAGMENTATION_DIR}"
export MULTIMER_OUTPUT_DIR="${MULTIMER_DIR}"
export ALPHAFRAGMENT_VENV="${ALPHAFRAGMENT_VENV}"
export ALPHAJUDGE_VENV="${ALPHAJUDGE_VENV}"
export MINIO="${MINIO}"
export ORGANISM="${ORGANISM}"
export BETA_PARAM="${BETA_PARAM}"
EOF

chmod +x "${BASE_DIR}/scripts/config.sh"

########################################
# Copy template scripts
########################################

cp "${SCRIPT_SOURCE_DIR}/run_create_features.sh" \
"${BASE_DIR}/scripts/"

cp "${SCRIPT_SOURCE_DIR}/protein_fragmentation.py" \
"${BASE_DIR}/scripts/"

cp "${SCRIPT_SOURCE_DIR}/run_protein_fragmentation.sh" \
"${BASE_DIR}/scripts/"

cp "${SCRIPT_SOURCE_DIR}/alphajudge_analysis.py" \
"${BASE_DIR}/scripts/"

cp "${SCRIPT_SOURCE_DIR}/run_alphajudge_analysis.sh" \
"${BASE_DIR}/scripts/"

cp "${SCRIPT_SOURCE_DIR}/run_multimer_jobs.sh" \
"${BASE_DIR}/scripts/"

cp "${SCRIPT_SOURCE_DIR}/download_features.py" \
"${BASE_DIR}/scripts/"

cp "${SCRIPT_SOURCE_DIR}/run_download_features.sh" \
"${BASE_DIR}/scripts/"

cp "${SCRIPT_SOURCE_DIR}/results_and_plots.py" \
"${BASE_DIR}/scripts/"

cp "${SCRIPT_SOURCE_DIR}/run_results_and_plots.sh" \
"${BASE_DIR}/scripts/"

########################################
# Make shell scripts executable
########################################

chmod +x \
"${BASE_DIR}/scripts/run_protein_fragmentation.sh" \
"${BASE_DIR}/scripts/run_create_features.sh" \
"${BASE_DIR}/scripts/run_multimer_jobs.sh" \
"${BASE_DIR}/scripts/run_alphajudge_analysis.sh" \
"${BASE_DIR}/scripts/run_download_features.sh" \
"${BASE_DIR}/scripts/run_results_and_plots.sh" \
"${BASE_DIR}/scripts/config.sh"

echo
echo "Created structure for pipeline execution on $DATASET in:"
echo "  ${BASE_DIR}"
