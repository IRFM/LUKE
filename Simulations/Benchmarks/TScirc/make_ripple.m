%************************************** MAGNETIC RIPPLE PARAMETERS ********************************************
%******************************************************************************************************************
% Create the local file RIPPLE_ripple_id.mat
% 
%by Y.Peysson CEA-DRFC <yves.peysson@cea.fr> and Joan Decker MIT-RLE (jodecker@mit.edu)
%
clear all
ripple_id = 'TScirc';%Set here the name (identifier) of the magnetic ripple parameters
%
ripple.nhuloss = NaN;%Magnetic ripple loss frequency, nhuloss > 1000 (or NaN if no ripple losses) (nhu_th) (WARNING: only valid for TORE SUPRA magentic equilibrium)
ripple.Ncoils = 18;%Number of coils for the toroidal magnetic field
%
eval(['save RIPPLE_',ripple_id,'.mat ripple']);