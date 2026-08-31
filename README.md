# chromatin-ppi-pipeline

The `chromatin-ppi-pipeline` is a computational workflow for protein-protein interaction identification and validation. 
Built on Alphapulldown2 using the Alphafold-Multimer folding backend, 
it aims to adress issues related to the large size of chromatin-associated proteins by dividing input proteins into smaller fragments
in a structurally informed manner.


## Pipeline structure
```
                                                   +--------------------+                                 
                                                   |Compute features    +---------+                       
                                                +->|  (MSAs, templates) |         v                       
+---------------------+   +---------------------+  +--------------------+   +----------------------------+
|input set of protein |   |Protein fragmentation|                           | Predict structures of      |
|names and Uniprot IDs+-->| using Alphafragment |                           | complexes using AF-Multimer|
+---------------------+   +---------------------+  +--------------------+   +---------------------+------+
                                                +->|Download precomputed|         ^               |       
                                                   |    features        +---------+               |       
                                                   +--------------------+                         |       
                                                                                                  |       
                                                                                                  |       
                                                                                                  |       
+---------------------+       +-----------------------------+      +-----------------------+      |       
| Generate output csv |<------+ Integrate fragment metrics  |<-----+   Score interfaces    | <----+       
|   and figures       |       | into protein metrics        |      |   using Alphajudge    |              
+---------------------+       +-----------------------------+      +-----------------------+              
```
This section offers a logical overview of the pipeline's functions. Details and syntax can be found in the Usage section TODO: link

On the input the pipeline expects a `.csv` file with a set of proteins specified by Uniprot IDs.
The Alphafragment Python package TODO: link is then used to fetch the amino acid sequences and structural features (known domains and motifs) of the specified proteins from Uniprot and Alphafold Protein Structure database.
The proteins are divided into fragments preferentially placing breaks outside of structured domains and introducing overlaps to recover the context of break loci.

On the fragmentation step a bait protein is specified by the user. Fragments are then paired into fragment-fragment complexes for structure predictions such that each fragment of the bait encounters every fragment of every interactor candidate.

Before proceeding with structure prediction the required features need to be aquired. These are per-protein `.pkl` files including serialized information about the multiple sequence alignments (MSAs), structure templates and other information for the folding backend (for more details refer to Alphapulldown2 documentation TODO:link).
There are two options for obtaining features:
- compute features locally (possible for any protein)
- download precomputed features from Alphapulldown features database (only possible for a set of model organisms selectable in the global configuration of the pipeline)

Once all features are available the structures of all fragment-fragment complexes are predicted using the Alphafold-Multimer folding backend.

The resulting structures are analyzed by the Alphajudge Python package TODO: link generating a summary with several metrics characterizing each interface including unified Alphafold-internal metrics (PAE, pLDDT), interface biophysics (e.g. number of hydrogen bonds, ) and derived scores (e.g. pDockQ).

To allow for comparison of interactions the information about individual fragment-fragment complexes is summarized for fragment pairs originating from the same pair of proteins using a softmax function yielding a value of the given metric representing the overall protein-protein interaction.
By default this is performed for the integrative **metascore** metric reported by Alphajudge which is used to rank the interactions.
Optionally any other numerical metric reported by Alphajudge can be specified by the user to also be summerized from fragments to proteins and reported for later analysis. 

To simplify the analysis of results exploratory figures showing the ranking by metascore and the distribution of metascores on the dataset are generated.
For the analysis of individual structures session scripts (TODO: link script usage) for the UCSF ChimeraX TODO: link molecular visualization software are provided allowing the user to quickly view any given interface.


## Installation instructions + dependencies

TODO: to be added soon 

## Usage
TODO: to be added soon 

