1) Download last version of MUMPS solver (http://graal.ens-lyon.fr/MUMPS/)
2) Put the MUMPS main directory where you want on your computer, and build MUMPS (sequential or parallel. Note both versions may be used, but must be build in separate directories)
3) copy $HOME/Packages/MUMPS/dke subdirectory into the MUMPS main directory
4) CD ~/MUMPS/dke. Open the README file and follow the instructions for building the MUMPS binary for DKE solver. The binary name is mumpsdke
5) CD $HOME/Database/PATH_files/. Modify the path file corresponding to your machine so that the MUMPS binary file for DKE may be found by MatLab
6) CD $HOME/Packages/MUMPS and open MUMPS_dke_yp.m file. Modify the m-file according to your environment, starting from the examples already given inside.
7) Select the option for using MUMPS in your favorite DKE parameter file placed in the directory $HOME/Database/DKEPARAM_files/ 

Note : 1) MUMPS_dke_yp.m is the interface of parallel or sequential versions of MUMPS (if one or several processors are used)
       2) MUMPSMEX_dke_yp.m is an implementation of a MEX version of MUMPS (sequential only). The sub-directory $HOME/Packages/MUMPS/MATLAB must be set in the MatLab path in this case.

