function [] = cleardmat(build_mode,dirname)
   cd(dirname)
   delete('*.mat')
   pause(2)
   info_dke_yp(2,['All *.mat files in ',dirname,' directory are removed.'])
   cd ..
end
