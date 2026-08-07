% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function data_out_netcdf = load_netcdf_jd(filename,listofvariables);
%
% This function loads netcdf data from the file 'filename' and returns a structure containing the variables from 'listofvariables'
%
if nargin < 2,
    %ncdisp(filename);%for details in the file (units,names,...)
    info_filename = ncinfo(filename);
    for ivar = 1:length(info_filename.Variables)
        listofvariables{ivar} = info_filename.Variables(ivar).Name;
    end
end
%****** OBSOLETE NETCDF INTERNAL MATLAB LIBRARY MIUST BE USED *************
if ischar(listofvariables) & strcmp(listofvariables,'toric'),%TORIC code data
    listofvariables = { 'Rtor',...
                        'Psi',...
                        'Den',...
                        'Tem',...
                        'Epsi',...
                        'q',...
                        'norqldce',...
                        'Vol',...
                        'Nu',...
                        'Umin',...
                        'Umax',...
                        'Qldce_LD',...
                        'Qldce_MXD',...
                        'Qldce_TTM',...
                        'Zeff',...
                        'johmic'};
end
%
% include test for matlab path of necessary functions
%
for iv = 1:length(listofvariables),
    eval(['data_out_netcdf.',listofvariables{iv},' = ncread(filename,listofvariables{iv});']);
end
    
     
