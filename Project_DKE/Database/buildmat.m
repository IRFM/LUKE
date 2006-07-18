function [] = buildmat(build_mode,dirname)
   cd(dirname)
   delete('*.mat')
   pause(2)
   filelist = dir(['make_',lower(dirname(1:strfind(dirname,'_'))),'*.m']);
   save temp.mat filelist dirname build_mode
%
   for i = 1:length(filelist),
      file = strrep(filelist(i,1).name,'.m','');
      if build_mode,
	     eval(file);
      else
         if isempty(strfind(file, 'h77'))
	        eval(file);
         end
      end  
      load temp.mat
   end
   info_dke_yp(2,['All *.mat files done in ',dirname,' directory.'])
   delete('temp.mat');
   cd ..
end
