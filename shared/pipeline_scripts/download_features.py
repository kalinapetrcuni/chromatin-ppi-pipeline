from pathlib import Path
import subprocess
import os
import pandas as pd

def download_features(uniprot_ids:list, outdir:str, path_to_mc:str, organism:str):

    outdir = Path(outdir)

    if not outdir.exists():
        raise FileNotFoundError(f"Target directory {outdir} for downloaded features does not exist.")

    if not outdir.is_dir():
        raise NotADirectoryError(f"Target {outdir} for downloaded features is not a direcotory.")
    
    cmd = [path_to_mc, "cp"]
    cmd.extend([f"embl/alphapulldown/input_features/{str(organism)}/{id}.pkl.xz" for id in uniprot_ids])
    cmd.append(str(outdir))

    subprocess.run(cmd, check=True)

# get paths to resources from enviroment variables 
path_to_MinIO_client = str(os.environ["MINIO"])
organism = str(os.environ["ORGANISM"])
features_output_directory = str(os.environ["FEATURES_OUTPUT_DIR"])
path_to_input_csv = Path(str(os.environ['SCRIPT_DIR'])).parent.resolve() / "input.csv" 

# load input csv
df = pd.read_csv(path_to_input_csv)

# extract Uniprot IDs
uniprot_ids = df["accession_id"].to_list()

# run the download
download_features(uniprot_ids=uniprot_ids, outdir=features_output_directory, path_to_mc=path_to_MinIO_client, organism=organism)
print("Finished feature download.")