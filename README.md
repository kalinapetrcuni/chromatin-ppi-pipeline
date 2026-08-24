# chromatin-ppi-pipeline

The `chromatin-ppi-pipeline` is a computational workflow for protein-protein interaction identification. 
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

```
                                                   ┌────────────────────┐                                 
                                                   │Compute features    ├─────────┐                       
                                                ┌─►│  (MSAs, templates) │         ▼                       
┌─────────────────────┐   ┌─────────────────────┤  └────────────────────┘   ┌────────────────────────────┐
│input set of protein │   │Protein fragmentation│                           │ Predict structures of      │
│names and Uniprot IDs├──►│ using Alphafragment │                           │ complexes using AF-Multimer│
└─────────────────────┘   └─────────────────────┤  ┌────────────────────┐   └─────────────────────┬──────┘
                                                └─►│Download precomputed│         ▲               │       
                                                   │    features        ├─────────┘               │       
                                                   └────────────────────┘                         │       
                                                                                                  │       
                                                                                                  │       
                                                                                                  │       
┌─────────────────────┐       ┌─────────────────────────────┐      ┌───────────────────────┐      │       
│ Generate output csv │◄──────┤ Integrate fragment metrics  │◄─────┤   Score interfaces    │ ◄────┘       
│   and figures       │       │ into protein metrics        │      │   using Alphajudge    │              
└─────────────────────┘       └─────────────────────────────┘      └───────────────────────┘              
```

## Installation instructions + dependencies

TODO: to be added soon 

## Usage
TODO: to be added soon 

