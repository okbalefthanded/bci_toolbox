# bci_toolbox (work in Progress)

A benchamark classification toolbox for ERP data

 Data sets available:
  1. BCI Compeition III Challenge 2004 (P300 evoked potentials) (http://www.bbci.de/competition/iii/)
  2. EPFL P300 data set (https://mmspg.epfl.ch/BCI_datasets)
  3. P300 speller with ALS patients (set #8) (http://bnci-horizon-2020.eu/database/data-sets)
  4. LARESI inverted face data set (coming soon)

- Processing methods available: 

- - Feature extraction: 
    --- Downsample
- - classification : 
  - - - LDA
  - - - Regularized LDA (shrinkage-LDA)
  - - - SWDLA
  - - - SVM (LIBSVM)
  - - - Logistic Regression (LIBLINEAR)
  - - - Random Forest 
  - - - SVM+ 
  
  # Setup
  - Download one of the Datasets (or all) in the list.
  - Create a new folder : "Dataset", create a new folder inside it "epochs".
  - Run one (or all, one by one) scripts related to each dataset in the dataio folder.
  - Run the script "define_approach_ERP.m"
  
  # Documentation
  coming soon
  
  # Cite us
  coming soon
