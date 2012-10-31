#!/bin/bash
#
# Filename: condor_matlab.sh
#
# Example of use:
# ./matlab.sh "function(a,c,'filename.txt')"
#

# run matlab in text mode 
exec "$LUKE_matlabroot"matlab  -nojvm -nodisplay -nosplash -r "$*"
