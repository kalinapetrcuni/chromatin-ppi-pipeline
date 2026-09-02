import sys
import alphafragment as af
import os 

if __name__ == "__main__":
    args = sys.argv
else:
    raise Exception("protein_fragmentation.py was not executed as a script")

# check that a bait protein was specified
if not len(args) > 1:
    raise ValueError("No bait protein specified. Please specify by protein name as first positional argument.")

if not str(args[1]):
    raise ValueError("No bait protein specified. Please specify by protein name as first positional argument.")

bait_protein = str(args[1]) # used as the "one" in one vs. all pairing

# assign paths to resources
input_csv = str(os.environ["INPUT_CSV"])
output_dir = str(os.environ["FRAGMENTATION_OUTPUT_DIR"])

save_fragmentation_figures=True



# define output paths
output_csv = f"{output_dir}/fragmented_proteins_data.csv"
save_figure_directory = f"{output_dir}/fragmentation_figures/"

# initialize proteins from CSV (as list of Protein objects and Dataframe)
proteins, df = af.process_proteins_csv.initialize_proteins_from_csv(input_csv)

for protein in proteins:
    # identify domains from Uniprot and AlphafoldDB
    domains = af.domain_compilation.compile_domains(protein, protein_data=df, uniprot=True, alphafold=True, manual=False)
    # add domains to the protein object
    for domain in domains:
        protein.add_domain(domain)

    # fragment the protein
    fragments = af.fragment_protein(protein) # can add args: len={"min": int, "ideal": int, "max": int}, overlap={"min": int, "ideal": int, "max": int}
    # add fragments to the protein object
    for fragment in fragments:
        protein.add_fragment(fragment)

    # plot fragmentation
    if save_fragmentation_figures:
        af.plot_fragments.plot_fragmentation_output(protein, fragments, save_figure_directory)


# write output CSV
af.process_proteins_csv.update_csv_with_fragments(df, output_csv, proteins)

# write protein-list.txt for Alphapulldown
af.fragment_file_creation.output_pulldown(proteins, method="one", one_protein=bait_protein, output_name=f"{output_dir}/alphapulldown-protein-list.txt", fasta_name=f"{output_dir}/alphapulldown-sequences.fasta")
