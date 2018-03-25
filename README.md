dk2_to_sk2_calculator
=======


An open source Matlab utility for time domain FLIM/FRET analysis of fluorescence decays originated from static randomly isotropically oriented donor-acceptor pairs. The influence of dipole-dipole orientation factor kappa-squared (k2) is modelled with the help of "static" ("sk2") FRET efficiency distribution. 

The calculator finds an sk2 decay closest to the fitted conventional double exponential decay ("dk2", corresponding to the dynamic random isotropic model of k2).

For further information please see:

Yuriy Alexandrov, Dino Solar Nikolic, Chris Dunsby, Paul M. W. French
"Quantitative time domain analysis of lifetime-based FRET measurements with fluorescent proteins: static random isotropic fluorophore orientation distributions", 
Journal of Biophotonics, 2018 (in press)


COMPATIBILITY
=======

1. Currently tested on Windows only
2. Microsoft Excel should be installed on the computer


TIPS ON USAGE
=======

0. Having the results of dk2 fitting (obtained with the help of software like FLIMfit), prepare the input Excel table.
Input table should contain 3 columns - "tau_D", "tau_DA", and "beta_DA" (molar fraction of FRET state). Lifetimes should be expressed in picoseconds.  Every row represents a fit of data to the dk2 model. 

1. After cloning repository from github, go to Matlab and run the file "dk2_to_sk2_calculator.m".

2. If running first time, wait until software finds Excel directory. It then displays small GUI window; this is single-button app.

3. Go to "File"->"Load data and calculate sk2 correction" and navigate to your input dk2 data table. 
After processing the input, the software will open results as Excel table with additional columns for corresponding sk2 parameters.



