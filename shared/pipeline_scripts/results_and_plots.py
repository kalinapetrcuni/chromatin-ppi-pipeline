import pandas as pd
import numpy as np
from pathlib import Path
import os
import sys

def parse_and_validate_requested_metrics(argument, alphajudge_df:pd.DataFrame) -> list:
    argument = str(argument)
    metric_list = [metric.strip() for metric in argument.split(",")]

    for metric in metric_list:
        if not metric in alphajudge_df.columns:
            raise ValueError(f"Invalid metric {metric} was requested.")

    return metric_list


def softmax(x, beta):
    """
    Returns the softmax of array-like x with parameter beta where 
    beta corresponds to 1/T (T = temperature).
    Varying the parameter beta causes the output probabilities to either concentrate mostly around the highest value in the input vector (high beta, low temperature)
    or spread the probability more evenly amongst entries in the input (low beta, high temperature).
    """
    return(np.exp(beta*x)/np.sum(np.exp(beta*x)))


def identify_interactors(df):
    """
    Extract the ID of the interactor protein and write it into a "interactor" column in the dataframe.
    """
    df1 = df.copy()
    mask = df1["jobs"].astype(str).str.contains("homo", na=False)

    df1["interactor"] = np.where(
        mask,
        df1["jobs"].str.split("_").str[0],
        df1["jobs"].str.split("_").str[3],
    )

    return(df1)


def group_by_interactor(df, metric:str):
    """
    Takes a Dataframe with "interactor" column and a column specified by "metric" as argument.
    Returns a dictionary with interactor IDs as keys and a list of each interactor fragments metric scores as the value: 
    {interactor_ID : [fragment1_value, fragment2_value, ...]}
    """

    fragment_metric_values = {}
    for _,row in df.iterrows():
        if row["interactor"] not in fragment_metric_values.keys():
            fragment_metric_values[row["interactor"]] = [row[metric]]
        else:
            fragment_metric_values[row["interactor"]].append(row[metric])
    return fragment_metric_values


def get_protein_metric_from_fragments(fragment_metrics:dict, beta):
    """
    Compute a protein score from a list of fragment scores for each dictionary entry.
    On input takes a dictionary with the following structure:
     {interactor_ID : [fragment1_score, fragment2_score, ...]} 
    Returns a dictionary with: {interactor_ID : interactor_score} 
    """
    protein_scores = {}
    for interactor in fragment_metrics.keys():
        fragment_metric_array = np.array(fragment_metrics[interactor])
        weights = softmax(fragment_metric_array, beta=beta)

        if interactor in protein_scores.keys():
            raise Exception("The same interactor was encountered multiple times")
        protein_score = np.sum(fragment_metric_array * weights)
        protein_scores[interactor] = protein_score

    return protein_scores


def join_metric_to_names(metric: dict, df, column_name:str):
    """
    Takes a dictionary in the form: {interactor_ID : metric_value},
    a dataframe with the names and IDs of all interactors 
    and the name of a column.
    Writes the metric value for corresponding proteins into the column specified by "colulumn_name". 
    Returns the dataframe with the new column.
    """
    df1 = df.copy()

    df1[column_name] = df1["accession_id"].map(metric)

    if df1[column_name].isna().any():
        raise Exception("Some proteins in names_and_IDs have no score in the dictionary.")

    return df1


def add_metric(alphajudge_output:pd.DataFrame, metric:str, names_and_ids:pd.DataFrame, beta ):
    """
    Wrapper for several other functions in this module.\n
    Extracts a specified metric from Alphajudge output, computes protein metric from fragments.

    Parameters
    ----------
    alphajudge_output - Alphajudge output csv as Pandas dataframe\n
    metric - corresponds to the column name to be extracted from the Alphajudge output.\n
    names_and_ids - dataframe with "name" and "accesion_id" columns (alike to the input of the entire pipeline)
    beta - parameter for softmax function (set using config)
    
    Returns
    -------
    Returns a dataframe with the names and IDs and the new metric column attached (preserves other columns except for column name conflicts with metric)
    """

    alphajudge_output1 = alphajudge_output.copy()

    metric_dict = get_protein_metric_from_fragments(group_by_interactor(identify_interactors(alphajudge_output1),metric=metric),beta=beta)
    new_column_name = "frag_" + metric
    out_df = join_metric_to_names(metric=metric_dict, df=names_and_ids, column_name=new_column_name)

    return out_df



# load alphajudge output
alphajudge_out_path = Path(os.environ["INPUT_CSV"]).resolve().parent / "interfaces_summary.csv"
if not alphajudge_out_path.is_file():
    raise FileNotFoundError(f"Alphajudge interfaces summary not found at {alphajudge_out_path}\n Please execute the Alphajudge analysis step first.")
alphajudge_output = pd.read_csv(alphajudge_out_path)

# load pipeline input csv
names_and_ids_path = Path(os.environ["INPUT_CSV"]).resolve()
if not names_and_ids_path.is_file():
    raise FileNotFoundError(f"Input csv not found at {names_and_ids_path}")
names_and_ids = pd.read_csv(names_and_ids_path)


# parse arguments
if __name__ == "__main__":
    args = sys.argv
else:
    raise Exception("results_and_plots.py was not executed as a script")

if not len(args) > 1:
    additional_metrics = []
else:
    additional_metrics = parse_and_validate_requested_metrics(args[1]) 

# set softmax beta parameter
beta_param = float(os.environ["BETA_PARAM"])


# extract the metascore
results_df = add_metric(alphajudge_output=alphajudge_output, metric="metascore", names_and_ids=names_and_ids, beta=beta_param)

# extract additional metrics requested by the user
if additional_metrics:
    for metric in additional_metrics:
        results_df = add_metric(alphajudge_output=alphajudge_output, metric=metric, names_and_ids=results_df, beta=beta_param)


# save the results csv
results_dir = Path(os.environ["INPUT_CSV"]).resolve().parent / "results"
if not results_dir.is_dir():
    raise FileNotFoundError(f"Couldn't save results.csv. Directory {results_dir} does not exist.")

results_df.to_csv(results_dir / "results.csv")


# TODO: plots, verify there is matplotlib in the env

