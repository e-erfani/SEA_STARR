# Pre- and Post-processing for the UW-SAM LES modeling of an intercomparison project called SEA STARR (Southeastern Atlantic Stratocumulus Transitions with Aerosol-Rain-Radiation interactions)

### Descriptions:
SEAS TARR is a collaborative numerical modeling work to study aerosol-cloud interaction over South-East Atlantic. Multiple international academic groups are involved. Each group conducted various Large Eddy Simulation (LES) experiments using their own model. At UW, SAM-UW was used. Only the pre- and post-processing of UW LES modeling outputs is documented here.

### Authors:
- The main post-processing Python code is developed by Ehsan Erfani.
- The Python codes regarding the conversion to DEPHY format are created by Michael Diamond for NOAA-SAM and are modified by Ehsan Erfani for UW-SAM.
- The pre-processing Matlab code is created by Peter Blossey and is modified by Ehsan Erfani to add new features and analyses.

### Codes:
- SEASTARR_postprocessing.ipynb: Use LES SAM UW model outputs and perform post-processing analysis.
- DEPHY_stat.ipynb: Convert SAM stat output to DEPHY standards for SEA STARR.
- DEPHY_2D.ipynb: Convert SAM 2D (x-y) output to DEPHY standards for SEA STARR.
- ConvertSEASTARRForcing.m: Generate the forcing file which is then used by SAM-UW as initial and boundary conditions. 

### Inputs:
- SAM-UW output files in NetCDF format.
- SAM-UW forcing file in NetCDF format.

### Requirements:
- Python3 in Jupyter Notebook (installed by Anaconda).
- See the beginning of each code for the required Python3 libraries.

### The analyses are featured in:
Diamond, et al., (2025) (including E. Erfani) work in progress.

Conference presentation:

Diamond, m., Ackerman, A., Baró Pérez, A., Bender, F., Ekman, A., Erfani, E., Fridlind, A., Feingold, G., Howes, C., Kazil, J., Saide, P., Wood, R., Yamaguchi, T., Zhang, J., Zhou, X., Zuidema, P. (2023). SE Atlantic Sc-Cu Transition with Aerosol-Radiation-Rain interactions (SEA STARR): An LES Intercomparison of Entrainment- and Precipitation-Driven Low Cloud Transitions in the Presence of Smoke. American Meteorological Society (AMS) Annual Meeting: Denver, CO, January 8, 2023-January 12, 2023
