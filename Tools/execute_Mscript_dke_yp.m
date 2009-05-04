function [] = execute_Mscript_dke_yp(script_name,script_path)
%LUKE - Function for executing any MatLab script without output
%
% Function for executing any MatLab script without output
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
cd(script_path);
eval([script_name,';']);
