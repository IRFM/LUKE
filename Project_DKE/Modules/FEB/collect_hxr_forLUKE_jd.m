function collect_hxr_forLUKE_jd(shot,data_path)
%
% This script collects and saves experimental HXR data
%
if nargin < 2,
    data_path = './';
end  
%
basestr = 'TCV';
%
data_file = ['HXREXP_',basestr,'_',num2str(shot),'.mat'];
%
collect_hxr;
%
save([data_path,data_file],'shot','energy','hxr','t','beta','filter_thickness','filter_material');
%
