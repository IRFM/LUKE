Set of examples for LHCD and Ohmic phases of the EAST tokamak discharge 043326 at times 2.9 s and 12 s respectively. 

Simulations using irunluke_jd:

- folder EAST_043326_002900 : Ohmic case

- folder EAST_043326_012000 : LH case (with and without anomalous fast electron radial transport, Dpsipsi = Dpsipsi0*(vpar/th) for vpar > 3.5 vth,
EM1 -> Dpsipsi0 = 1 m2/s, EM2 -> Dpsipsi0 = 2 m2/s). Simplified launched LH power spectrum @ 2.45GHz

- folder EAST_043326_012000_HFS : LH case (with and without anomalous fast electron radial transport, Dpsipsi = Dpsipsi0*(vpar/th) for vpar > 3.5 vth,
EM1 -> Dpsipsi0 = 1 m2/s, EM2 -> Dpsipsi0 = 2 m2/s). Simplified launched LH power spectrum @ 2.45GHz. The antenna has been put in the high magnetic field side.

- folder EAST_043326_012000_ALOHA: LH case (with and without anomalous fast electron radial transport, Dpsipsi = Dpsipsi0*(vpar/th) for vpar > 3.5 vth,
EM1 -> Dpsipsi0 = 1 m2/s, EM2 -> Dpsipsi0 = 2 m2/s). Launched LH power spectrum @ 2.45GHz calculated by the ALOHA antenna code with zero waveguide phasing


Procedure for the case EAST_043326_012000

1) launch Matlab and initialize for LUKE
2) move to the chosen folder
3) run irunluke_jd, answer 0 to the first query, then EAST to the second one
4) then choose menu 4), menu 2) (new 'external' structure), menu 1) (Local interactive calculation)
5) set wordir = full absolute path, shotnum = 043326, shotime = 012000
6) type 0, and 0 again, and save the external structure separately (convenient)
7) confirm the automatic name (recommended) or change it, and save
8) back to the main menu, choose menu 2) to save the simulation (automatic name proposed, recommended) 
9) choose menu 6) for LUKE parameters (choose menu 5) and save)
10) choose menu 7) for creating a new 'equil' from the menu 2) from the external data (magnetic and profiles). Results can be displayed. Save 'equil' in an indepedent file.
11) back to the main menu, choose menu 2) to save the simulation (updated automatic name proposed, recommended) 
12) choose menu 8) for creating a new 'wave' from the menu 1) from the external data. Results can be displayed. Expert mode allows to access
to other parameters, like HFS or LFS (default). Choose 1) C3PO ray-tracing that comes with LUKE for calculating the ray propagation. Choose the machine et the calculation mode (sequential or 
parallel to speed-up the calculations). Once done - may take some time depending of the number of rays - save the 'wave' results in an indepedent file.
13) back to the main menu, choose menu 2) to save the simulation (updated automatic name proposed, recommended) 
14) choose menu 0) to run LUKE Fokker-Planck using wave data (if any): local or distributed computing (recommended, because may be long)
15) back to the main menu, choose menu 2) to save the simulation (updated automatic name proposed, recommended)
16) choose menu 0) to run fast electron bremsstrahlung calculations from kinetic results: local or distributed computing (recommended, because may be long)
17) back to the main menu, choose menu 2) to save the simulation (updated automatic name proposed, recommended)

All simulations are in principle done. The results may be viewed 




----------------------------------

Simulations using scripts :

- folder EAST_043326_012000_scan: LH case, (Npar0,PLH) scan or (antenna phasing,PLH) scan with or without the tail model for the initial launching conditions (main lobe only) 
or anomalous fast electron radial transport, Dpsipsi = Dpsipsi0*(vpar/th) for vpar > 3.5 vth, EM2 -> Dpsipsi0 = 2 m2/s). Use the remote + distributed computing capability

1) edit the scripts, and modify the machine on which calculations should be done (type select_LUKE before running the script, to know the machine number available)
2) run the script. 
3) rerun the script to get the simulation status and download results is some points of the scan are already available. Do it as many times as necessary, until the whole simulation is done
Several options may be modified, in particular to rerun broken cases because of network problems. Once more than 50% of the simulations are done, the figures are automatically generated. 



