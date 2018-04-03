# bci_toolbox (work in Progress)

A benchamark classification toolbox for ERP data

 Data sets available:
 
 ## ERP Data sets:
  1. BCI Compeition III Challenge 2004 (P300 evoked potentials) (http://www.bbci.de/competition/iii/)
  2. EPFL P300 data set (https://mmspg.epfl.ch/BCI_datasets)
  3. P300 speller with ALS patients (set #8) (http://bnci-horizon-2020.eu/database/data-sets)
  4. LARESI inverted face data set (coming soon)

## SSVEP Data sets:
  1. SSVEP Exoskeleton (https://old.datahub.io/dataset/dataset-ssvep-exoskeleton)
  2. Tsinghua Joint Frequenty-Phase Modulation SSVEP (http://www.thubci.org/en/?a=nr&id=100)


- Processing methods available: 

- - Feature extraction: 
    --- Downsample
    --- Multivariate Linear Regression(MLR)
- - classification : 
  - - - LDA
  - - - Regularized LDA (shrinkage-LDA)
  - - - SWDLA
  - - - SVM (LIBSVM)
  - - - Logistic Regression (LIBLINEAR)
  - - - Random Forest 
  - - - SVM+ 
  - - - CCA, L1-Multiway CCA, Mset CCA, TRCA
  
  
  # Setup
  Run the setup.m script
  
  # Usage
  ## First run
  - Download one of the Datasets (or all) in the list.
  - create a new folder inside the Dataset/epochs.
  - Run one (or all, one by one) scripts related to each dataset in the dataio folder.
  
  ## Regular usage
  - Run the script "define_approach_ERP.m" for ERP data
  - Run the script "define_approach_SSVEP.m" for SSVEP data
  
  # Documentation
  coming soon
  
  # Cite us
  coming soon
