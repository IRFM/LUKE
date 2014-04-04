function [] = test_equiconsistency_yp(filein,equilformat)
% LUKE - Test the consistency of the of a toroidal MHD equilibrium in a file
%
% Test the consistency of the of a toroidal MHD equilibrium in a file
%
% INPUT
%
%    - filename: name of the file that contains the toroidal MHD equilibrium
%    - equilformat: file format of toroidal MHD equilibrium (LUKE, EQDSK, EFIT, ACCOME, HELENA, CHEASE, etc)
%
% OUTPUT: 
%
%    - 
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin <= 0,
    filein = input_dke_yp('Enter the file name (with extension) of the toroidal MHD equilibrium','');
end
%
if nargin <= 1,
    equilformat = input_dke_yp('Enter the file format of the toroidal MHD equilibrium ','LUKE, EQDSK, EFIT, ACCOME,...');
end
%
[filepath,filename,fileext] = fileparts(filein);
%
%
if strcmp(equilformat,'LUKE'),
    %
    data = importdata(filein);%load data from filein into the workspace
    %
    if ~isfield(data,'psi_apRp'),%LUKE format.
        error(['The file ',filename,fileext,' does not contains an equil structure (LUKE equilibrium format)']);
    else
        equil = data;
    end   
elseif strcmp(equilformat,'EFIT') || strcmp(equilformat,'EQDSK'),
    %
    if strcmp(fileext,'.mat'),
        equil = equil_EFIT_jd(filename,1,2,-1);       
    else
        flag = 0;
        %
        if strcmp(fileext,'efit') == 0,
            unix(['cp ',filename,fileext,' ',filename,'.efit']);
            filein_tmp = [filename,'.efit']; 
            flag = 1;
        end
        %
        equil = equil_EFIT_jd(filename,0,2,0);
        %
        if flag,unix(['rm -f ',filein_tmp]);end
    end
    %
elseif strcmp(equilformat,'ACCOME'),
    %
    if isempty(fileext)
        data1 = importdata([filename,'.bfield']);%load data from filein into the workspace
        data2 = importdata([filename,'.params']);%load data from filein into the workspace
    elseif strcmp(fileext,'.bfield')
        data1 = importdata(filein);%load data from filein into the workspace
        %
        if exist([filename,'.params'],'file'),
            data2 = importdata([filename,'.params']);%load data from filein into the workspace
        end
    elseif strcmp(fileext,'.params')
        if exist([filename,'.bfield'],'file'),
            data1 = importdata([filename,'.bfield']);%load data from filein into the workspace
        end
        %
        data2 = importdata(filein);%load data from filein into the workspace
    end
    %
    [equil_magnetic,prho,psin] = equil_magnetic_ACCOME_yp(filename,0,-1,filename,filename);
    %
    equil_prof = equil_prof_ACCOME_yp(filename,NaN,[],psin,0,-1,filename,filename,NaN);
    %
    equil = conc_struct_jd(equil_magnetic,equil_prof);
    %
    equil.id = filename;
    %
    save(['EQUIL_',filename,'.mat'],'equil');
else
    error('Unknown toroidal MHD equilibrium file format');
end
%   
disp('Calculation of the equilibrium consistency (wait few seconds).');    
%
[equil,gradpthermalsgradrho,gradpmagsgradrho,gradpkinsgradrho,jparz_fsav,jparz_ohm_fsav] = equilconsistency_yp(equil,'',1);
    

