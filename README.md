
# Precision functional mapping
Code and data accompanying the article Frontostriatal salience network expands as executive networks contract in Obsessive-Compulsive Disorder (Vaghi et al.,)

This codebase contains code for delineating functional brain networks entirely within individual subjects, a procedure called precision functional mapping (PFM; see Gordon et al. 2017 Neuron).

## Background
The PFM code has been forked from https://github.com/cjl2007/PFM-Depression (see Lynch et al., Nature 2024)

## Example PFM datasets
Data from the MyConnectome and the Midnight Scan Club (MSC) datasets included in this paper were obtained online (https://openneuro.org/) in a preprocessed, fully denoised and surface-registered format, and no further preprocessing or denoising was performed for the present study. The MyConnectome dataset is available on OpenNeuro repository at https://openneuro.org/datasets/ds000031/versions/2.0.2 and the MSC dataset is available on OpenNeuro repository at https://openneuro.org/datasets/ds000224/versions/1.0.4.

## Usage
 The "pfm_tutorial_MSC.m" script (located in the ~/PFM-Tutorial) calls multiple Matlab scripts for performing PFM. The code can be run using data from the MSC (available at https://openneuro.org/datasets/ds000224/versions/1.0.4) and adapted for other PFM-style datasets.

A series of scripts and softwares which are required to run the code are also included.

* ~/PFM-Tutorial/read_write_cifti:  scripts to read the cifti files (copied from https://github.com/MidnightScanClub/MSCcodebase/tree/master/Utilities/read_write_cifti)

 * ~/PFM-Tutorial/Resources: code to run the infomap (downloaded from www.mapequation.org)

* ~/PFM-Tutorial/workbench: code to access functions from the Workbench Connectome (downloaded from http://www.humanconnectome.org/software/connectome-workbench.html)

In addition, usage of the code will require access to Matlab R2022b, https://www.mathworks.com/.

Once you have downloaded the example dataset from OpenNeuro.org and checked that all of the necessary dependencies are available, you can open  the pfm_tutorial_MSC.m script in the Matlab editor window and run it. Comments within the script provide further instructions on each step and expected output.

Please note that the download of data is rather large. For example MSC was scanned over 10 imaging sessions (~ 5 hours of functional MRI resting-state data). Installation of software will be fast and straightforward (~ 10 mins including downloading, unzipping and basic testing for each of the relevant softwares).Running the pipeline on real data requires a lot of memory, and so we don't recommend running this on a personal computer. 
