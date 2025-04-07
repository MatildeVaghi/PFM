This codebase contains code for delineating functional brain networks entirely within individual subjects, a procedure called precision functional mapping (PFM; see Gordon et al. 2017 Neuron).

The code has been forked from https://github.com/cjl2007/PFM-Depression (see Lynch et al., Nature 2024). The "pfm_tutorial.m" script (located in the ~/PFM-Depression/PFM-Tutorial) calls multiple Matlab scripts for performing PFM from ~/PFM-Depression/PFM-Tutorial/Utilities and it has been minimally adapted for working with Midnight Scan Club Data. 

This repo also includes a series or scripts which are required to run the code: 
- The folder ~/read_write_cifti contains a series of scripts to read the cifti files and it has been copied from https://github.com/MidnightScanClub/MSCcodebase/tree/master/Utilities/read_write_cifti
- The folder ~/Resources contains code to run the infomap and it has been downloaded from www.mapequation.org
- The folder ~/workbench contains code to access functions from the Workbench Connectome and it has been downloaded from http://www.humanconnectome.org/software/connectome-workbench.html

