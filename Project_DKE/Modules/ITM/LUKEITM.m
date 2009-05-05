function [struct_name,struct_path] = LUKEITM(dkepath,name)
%LUKE - Function that gives the correspondance between the name of a LUKE structure and its number in the ITM MDS+ database
%
%Function that gives the correspondance between the name of a LUKE structure and its number in the ITM MDS+ database
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 2,error('Not enough input arguments in LUKEITM.m');end
%
if strcmp(name,'equil'),
	equil_name{1} = 'TScyl';path_equil{1} = '';
	equil_name{2} = 'TScirc';path_equil{2} = '';
	equil_name{3} = 'TScirc_peak';path_equil{3} = '';
	equil_name{4} = 'TScirc_e1';path_equil{4} = '';
	equil_name{5} = 'TScyl_lowTene';path_equil{5} = '';
	equil_name{6} = 'JETh77';path_equil{6} = '';
	equil_name{7} = 'JETliketest';path_equil{7} = [dkepath.luke_root,'Project_DKE/Modules/RT/Examples/JETlike/EQUIL/'];% Magnetic equilibrium from ~/LUKE/Project_DKE/Modules/RT/Examples/***/EQUIL/
	equil_name{8} = 'PLTtest';path_equil{8} = [dkepath.luke_root,'Project_DKE/Modules/RT/Examples/PLT/EQUIL/'];% Magnetic equilibrium from ~/LUKE/Project_DKE/Modules/RT/Examples/***/EQUIL/
	equil_name{9} = 'VERSATOR2test';path_equil{9} = [dkepath.luke_root,'Project_DKE/Modules/RT/Examples/VERSATOR2/EQUIL/'];% Magnetic equilibrium from ~/LUKE/Project_DKE/Modules/RT/Examples/***/EQUIL/
	equil_name{10} = 'RTtest';path_equil{10} = [dkepath.luke_root,'Project_DKE/Modules/RT/Examples/RTtest/EQUIL/'];% Magnetic equilibrium from ~/LUKE/Project_DKE/Modules/RT/Examples/***/EQUIL/
	equil_name{11} = 'RTtest_vacuum';path_equil{11} = [dkepath.luke_root,'Project_DKE/Modules/RT/Examples/RTtest/EQUIL/'];% Magnetic equilibrium from ~/LUKE/Project_DKE/Modules/RT/Examples/***/EQUIL/
	equil_name{12} = 'RFP';path_equil{12} = [dkepath.luke_root,'Project_DKE/Modules/RT/Examples/RFP/EQUIL/'];% Magnetic equilibrium from ~/LUKE/Project_DKE/Modules/RT/Examples/***/EQUIL/
	equil_name{13} = 'ITER_Scen4_IAEA06';path_equil{13} = [dkepath.luke_root,'Simulations/Examples/ITER/Scen4/EQUIL/'];% Magnetic equilibrium from ~/LUKE/Simulations/
	equil_name{14} = 'CRONOS_32299_k100';path_equil{14} = [dkepath.luke_root,'Simulations/Examples/TS/32299/EQUIL/'];% Magnetic equilibrium from ~/LUKE/Simulations/
	%
	struct_name = equil_name;
	struct_path = path_equil;
elseif strcmp(name,'wave'),
	%
    wave_name{1} = 'WAVE_ITER_Scen4_IAEA06_20Z';path_wave{1} = [dkepath.luke_root,'Simulations/Examples/ITER/Scen4/WAVE/C3PO/'];% Magnetic equilibrium from ~/LUKE/Simulations/
	%
	struct_name = wave_name;
	struct_path = path_wave;
end
%