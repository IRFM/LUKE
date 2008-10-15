function mex_clean_luke(luke_root)
%
mexpath = [luke_root,'Project_DKE/MEX/Bin/'];
%
foldercontent = dir(mexpath);
%
for icont = 1:length(foldercontent),
    if foldercontent(icont).isdir...
            && ~strcmp(foldercontent(icont).name,'.')...
            && ~strcmp(foldercontent(icont).name,'..')...
            && ~strcmp(foldercontent(icont).name,'CVS'),
        rmdir([mexpath,foldercontent(icont).name],'s');
    elseif ~foldercontent(icont).isdir && ~strcmp(foldercontent(icont).name,'readme.txt'), 
        delete([mexpath,foldercontent(icont).name]);
    end
end
%
disp(['The mexfiles has been removed.'])
%