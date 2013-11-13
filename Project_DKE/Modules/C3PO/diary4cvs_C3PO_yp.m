function [] = diary4cvs_C3PO_yp(id_wave,dkepath,waves)
% C3PO - diary output for CVS error tracking in C3PO examples 
%
% Diary output for CVS error tracking in C3PO examples
%
% INPUT:
%
%    - id_wave: id of the C3PO example
%    - dkepath: dkepath structure
%    - waves: list of waves
%
% OUTPUT: none
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
diaryname = ['res_',id_wave,'.log'];
[LUKEversion,matver] = LUKEversion_jd;
%
if exist(diaryname,'file'),
    delete(diaryname)
end
%
diary(diaryname)
%
disp(['Simulation id: ',id_wave]);
disp(['Simulation date: ',timeid_jd(timeid_jd(clock))]);
disp(['User id: ',userid_jd]);
disp(['LUKE Version: ',LUKEversion]);
disp(['MATLAB Version: ',matver]);
disp(['MACHINE: ',dkepath.hostname]);
%
for ii = 1:7
    for jj = 1:4,
        format_disp{ii,jj} = '%17.15f';
    end
end
%
if ~iscell(waves), waves = {waves};end
%
for iw = 1:length(waves),
    disp(['---------------------- ',waves{iw}.id,' ----------------------'])
    %
    jj = 1;
    %
    for ir = [1,10,100,1000],
        if length(waves{iw}.rays{1}.sx) >= ir,
            disp(['sx(',int2str(ir),')    = ',num2str(waves{iw}.rays{1}.sx(ir),format_disp{1,jj})])
            disp(['sy(',int2str(ir),')    = ',num2str(waves{iw}.rays{1}.sy(ir),format_disp{2,jj})])
            disp(['sz(',int2str(ir),')    = ',num2str(waves{iw}.rays{1}.sz(ir),format_disp{3,jj})])
            disp(['ss(',int2str(ir),')    = ',num2str(waves{iw}.rays{1}.ss(ir),format_disp{4,jj})])
            disp(['skrho(',int2str(ir),') = ',num2str(waves{iw}.rays{1}.skrho(ir),format_disp{5,jj})])
            disp(['sm(',int2str(ir),')    = ',num2str(waves{iw}.rays{1}.sm(ir),format_disp{6,jj})])
            disp(['sn(',int2str(ir),')    = ',num2str(waves{iw}.rays{1}.sn(ir),format_disp{7,jj})])
            if jj < 4,disp('----------------------');end
        end
        jj = jj + 1;
    end
    %
    diary off
end
