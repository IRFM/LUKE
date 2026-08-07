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
function infostr = iluke_waveinfo(waves)
%
if isstruct(waves{1})
    nw = length(waves);
    infostr = cell(1,nw);
    for iw = 1:nw,
        infostr{iw} = ['Wave # ',num2str(iw),'   Type : ',waves{iw}.rayinit.launch.type,'   Id : ',waves{iw}.id];
    end
else
    nit = length(waves);
    nw = length(waves{1});
    infostr = cell(1,nw+2);
    infostr{1} = ['Fluctuations : ',num2str(nit),' states.'];
    infostr{2} = ' ';
    for iw = 1:nw,
        is1 = max(strfind(waves{1}{iw},'WAVE_'));%wavess contains wave files 
        is2 = strfind(waves{1}{iw},'_itn_1.mat') - 1;
        %
        infostr{2+iw} = ['Wave # ',num2str(iw),' : ',waves{1}{iw}(is1:is2)];
    end
end
