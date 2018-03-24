dk2_to_sk2_calculator
=======


An open source Matlab utility for the time domain FLIM/FRET analysis of static isotropic donor-acceptor pairs. 

The calculator finds static kappa squared (sk2) decay closest to the fitted conventional double exponential decay (dk2).

For further information please see:

Yuriy Alexandrov, Dino Solar Nikolic, Chris Dunsby, Paul M. W. French
"Quantitative time domain analysis of lifetime-based FRET measurements with fluorescent proteins: static random isotropic fluorophore orientation distributions", 
Journal of Biophotonics, 2018 (in press)


COMPATIBILITY
=======

1. Currently tested on Windows only
2. Excel should be installed on the computer


TIPS ON USAGE
=======

0. Having the results of dk2 fitting (obtained with the help of software like FLIMfit), prepare the input Excel table.
Input table should contain 3 columns - "tau_D", "tau_DA", and "beta_DA". 


1. After cloning repository from github, go to Matlab and run the file "dk2_to_sk2_calculator.m".

2. Wait until software finds Excel directory and displays small GUI window. This is single button app.

3. Go to "File"->"Load data and calculate sk2 correction" and navigate to your input dk2 data table. 
After processing the input, the software will open results as Excel table with additional columns for sk2 parameters.



