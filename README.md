# JPk Data Analysis Codes

This codes are being made (in MATLAB) during my thesis to work on JPk-analysed data obtained through microrheology experiments. 
The codes do different things, from organizing the .tsv file to extracting the Young Modulus or G' and G". 
All the codes and their limitation are explained with comments and all of them can be upgraded in some way.

## Code 1
A small code that convert .tsv file into a MATLAB cell, it has some severe limitation on the way the file are inputted, which is explained in the code, and its also need two function (organize_data and organized_checked_data) to work.
The code also work with files where in the jpk analysis frequencies were discarded, the way in which this is handled is described in the code. 
The code also gives the user some freedom in the .mat name.

## Code 2
This code is just to analyse data from classic indentation experiments, there are some precautions to watch for that are linked to the given protocol during the acquisiton, but are easily tweakable.
The code plot the median and the CI of the YM, it also take into account NaN values that can be present "naturally" or from Code 1.
The plot is easily customable.

## Code 3
This code is to analyse data from microrheology experiments, as in Code 2 there are some precautions to watch for that are easily tweakable. 
It does the fit of both the median and CI of G' and G" with both a signle exponential and double exponential, it also takes into account the NaN values as Code 2.
The plot is easily customable.
