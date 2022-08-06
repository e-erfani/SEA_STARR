# Pre- and Post-processing for the LES modeling of the SEASTARR project

### Descriptions:
SEASTARR is a collaborative numerical modeling work to study aerosol-cloud interaction over South-East Atlantic. Multiple international academic groups are involved. Each group conducted various Large Eddy Simulation (LES) experiments using their own model. At UW, SAM-UW was used. Only the post-processing of UW LES modeling outputs is documented here.

### Authors:
- The main post-processing code is developed by Ehsan Erfani.
- The codes regarding the conversion to DEPHY format are created by Michael Diamond for NOAA-SAM and are modified by Ehsan Erfani for UW-SAM.
- The Matlab code for generating the forcing file is created by Peter Blossey and is modified by Ehsan Erfani to add new features and analyses.

### Codes:
- SEASTARR_postprocessing.ipynb: Use LES SAM UW model outputs and perform post-processing analysis
- DEPHY_stat.ipynb: Convert SAM stat output to DEPHY standards for SEA STARR
- DEPHY_2D.ipynb:   Convert SAM 2D (x-y) output to DEPHY standards for SEA STARR

### Inputs:
- SAM-UW output files in NetCDF format.
- SAM-UW forcing file in NetCDF format.

### Requirements:
- Python3 in Jupyter Notebook (installed by Anaconda).
- See the beginning of each code for the required Python3 libraries.
