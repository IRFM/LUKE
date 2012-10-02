#!/bin/bash
#
# Filename: condor_matlab.sh
#
#
# run matlab in text mode 
exec "$remotebatch_matlabroot"matlab  -nojvm -nodesktop -nodisplay -nosplash -r "addpath('$remotebatch_path');disp([' Path set to $remotebatch_path']);$*"

