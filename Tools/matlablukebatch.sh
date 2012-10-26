#!/bin/bash
#
# Filename: matlablukebatch.sh
#
# Standard matlab batch start where the generic function remotematrun is called after setting the path to the LUKE environment
#
"$remotebatch_matlabroot"matlab -nodesktop -nodisplay -nosplash -r "luke_root = getenv('luke_root');addpath([luke_root,'Project_DKE/DKE']);setpath_luke_jd(luke_root);disp([' Path set to ',luke_root]);remotematrun;exit"

