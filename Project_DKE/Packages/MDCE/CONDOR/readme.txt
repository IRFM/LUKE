
Test outside matlab (standalone application)

1) compile the program simple.c  (type 'gcc simple.c -o simple')
2) test the program simple localy (type 'simple 4 10')
3) test condor execution (type 'condor_submit simple.condor', and see the log, err and output files)

Test inside matlab (standalone application)

1) In Matlab, execute the script make_condortest.m which creates the condor script matlabtest.condor 
for the computer on which condor batcch scheduler is running, and for the corresponding matlab version. By default, 
the condor settings run for the logged user.
2) type pwd in Matlab command window. Copy the path of the working directory.
3) open a terminal
4) move to the working directory
5) type: condor_status (the list of available slots should be listed, otherwise, type condor_master)
6) type: condor_submit matlabtest.condor

The results are put automaticaly in the directory in files test_condor_x-1.txt with x ranging from 5 to 10. 
Corresponding error err.x and log files log.x are also created in the working directory
