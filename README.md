# PSN-QA
PSN-QA evaluates a protein structure (PDB, modelled, decoy) from its network perspective. The network has been constructed on the basis of non-covalent interactions between side chains of the polypeptide chain.
### BACKGROUND #### 

"NetQPred (Network for Quality Prediction)" uses protein structure networks [PSNs] in combination with support vector machine to study the quality of a protein model. It has been shown in our previous work that network parameters from the PSN of a native, well connected structure show a characteristic profile when plotted against the strength of the interaction between the nodes (residues). This characteristic profile has been exploited in this method to generate a classifier for protein model quality prediction. The classification scheme used is binary in nature and provides  a “yes/no” output. To overcome this, we went a step ahead and provided ranks to each of the model being checked. For ranking, we used L2-regularized L2-loss ranking method. The ranks could clearly discriminate the native structures from the non-native like structure. Generally, it is observed that native like structures, score rank equal to or greater than 16. 

For details, please refer to "Network properties of decoys and CASP predicted models: a comparison with native protein structures; Mol. BioSyst. , 2013, 9, 1774-1788" 

### PROTOCOL ### 

Step 1. Data pruning 
Step 2. Generate PSNs 
Step 3. Calculate network parameters at different Imins 
Step 4. Test using libSVM model 
Step 5. Get ranks for all the models (option 0) or for the positively selected models from Step 4 (option 1: default). 

### Requirements ### 

Operating System : Linux 
NetQPred folder 

## This is a preinstalled version !!! ## 

### INPUT ### 

Folder containing the models for quality testing. 

to run : 
> bash NetQPred <input folder> 

### OUTPUT ### 

Output files "models_classified", contain the binary classification using libSVM while "models_ranked" contains the rank for the model (models will depend on user option). Both files are stored in the RESULTS folder. 

For the curious mind, 

Detailed results and other intermediate files are stored in different folders inside the <input folder>. 

"Adj" : contains the adjacency matrices for all models at different Imins. (Note, that different chains are considered as independent models) 
"NAN" : contains the rejected PDBs based on dataset pruning ( size less than 100, empty files etc) 
"network_params" : contains the values of the networks parameters calculated at different Imins
"PDB_culled" : contains the list of correspondences between the residue numbers in the PDB files and the node ids in the matrices. Mostly useful, when PDB contains missing residues or when the residue numbering in the PDB file does not start with 1.
"SVM_analysis" : contains all files related to SVM analysis. Specifically, libSVM and libRank models.
