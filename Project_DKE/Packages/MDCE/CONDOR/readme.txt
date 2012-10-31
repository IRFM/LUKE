
1) In Matlab, execute the script make_condortest.m which creates the condor script matlabtest.condor 
for the computer on which condor batcch scheduler is running, and for the corresponding matlab version. By default, 
the condor settings run for the logged user.
2) open a terminal
3) move to this directory
4) type: condor_status (the list of available slots should be listed, otherwise, type condor_master)
5) type: condor_submit matlabtest.condor

The results are put automaticaly in the directory in files test_condor_x-1.txt with x ranging from 5 to 10. 
Corresponding error err.x and log files log.x are also created in the working directory
