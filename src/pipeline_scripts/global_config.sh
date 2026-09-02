#!/bin/bash

# path to Alphafragment venv virtual enviroment
export ALPHAFRAGMENT_VENV=""

# path to Alphajudge mamba enviroment
export ALPHAJUDGE_VENV=""

# path MinIO Client binary 
export MINIO=""

# If you plan to download precomputed features for proteins of model organisms via MinIO client
# select an organism by uncommenting the corresponding line (ONLY ONE !!!)
# Please uncomment the blank option if you don't plan on using the download to prevent the ORGANISM variable being undefined. 
#export ORGANISM=""
export ORGANISM="Homo_sapiens"
#export ORGANISM="Escherichia_coli"
#export ORGANISM="Mus_musculus"
#export ORGANISM="Drosophila_melanogaster"
#export ORGANISM="Danio_rerio"
#export ORGANISM="Caenorhabditis_elegans"
#export ORGANISM="Dictyostelium_discoideum"
#export ORGANISM="Methanocaldococcus_jannaschii"
#export ORGANISM="Rattus_norvegicus"
#export ORGANISM="Saccharomyces_cerevisiae"
#export ORGANISM="Oryza_sativa"
#export ORGANISM="Zea_mays"
#export ORGANISM="Glycine_max"
#export ORGANISM="Arabidopsis_thaliana"

# beta parameter for softmax function - used to integrate fragment metrics into protein metrics -> see docs for interpretation
export BETA_PARAM=5