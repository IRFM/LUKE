function save_batch_jd(lukestructs,dkepath,savestr,savepath)
%
% This function saves the results from run_lukert in a file for laterprocessing
%
if nargin < 4,
    savepath = '.';
end
if nargin < 3,
    savestr = '';
end
%
if ~isempty(savestr),
    savestr = ['_',savestr];
end
%
filename = [savepath,filesep,'LUKE_BATCH',savestr,'.mat'];
%
ifilenum = 0;
while exist(filename,'file'),% to avoid overwriting existing batch file
    ifilenum = ifilenum + 1;
    filename = [savepath,filesep,'LUKE_BATCH',savestr,'_',num2str(ifilenum),'.mat'];
end   
%
save(filename,'lukestructs','dkepath')
%
if isfield(lukestructs{1},'job'),
    disp(['Jobs info saved in ',filename])
else
    disp(['LUKE Results saved in ',filename])
end
