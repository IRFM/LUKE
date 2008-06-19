%LUKE - Test function for LUKE distributed computing environment
%
clear functions
clear mex
%
if exist(fullfile(getenv('HOME'),'.dcluke.mat'),'file')
	delete(fullfile(getenv('HOME'),'.dcluke.mat'));
end
dirini = pwd;
if exist(fullfile(getenv('HOME'),'tmp'))
	cd(fullfile(getenv('HOME'),'tmp'));
	filelist = ls;
	if isempty(filelist),
		delete('*');
	end
end
cd(dirini);
%
dcluke(0,'RESET');
%
id = dcluke('fundcluke',pi/3);  
dcluke;
disp('LUKE distributed computing');
tic,[e1_d,e2_d,e3_d] = dcluke(id);toc
%
disp('LUKE sequential computing');
tic,[e1,e2,e3] = fundcluke(pi/3);toc
%
disp('results:');
[[e1,e1_d];[e2,e2_d];[e3,e3_d]]
