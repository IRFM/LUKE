function frundke_fluctn(lukestructs,dkepath,opt_save,p_opt,path_simul,dtn,tn,Nfluct,sigmar_max,sigmar_hwhm)
%
id_simul = lukestructs.id_simul;
dkeparam = lukestructs.dkeparam;
equil = lukestructs.equil;
%
% in this scan, the imaginary part of tn specifies the number of iterations if Nfluct = 1
% - dkeparam.tn is adjusted to have final time constant
% - dkeparam.dtn is adjusted to have internal time step constant
if imag(tn) > 0,
    dkeparam.tn = tn/Nfluct;% as an imaginary number, dkeparam.tn prescribes the number of fluctuation iterations
else % in this scan, a real tn specifies the final time explicitly
    dkeparam.tn = tn;% as an imaginary number, dkeparam.tn prescribes the number of fluctuation iterations
end
if imag(dtn) > 0,
    dkeparam.dtn = dtn*Nfluct;% internal LUKE time step. As an imaginary number, dkeparam.dtn prescribes the number of internal time steps
else % in this scan, a real tn specifies the final time explicitly
    dkeparam.dtn = dtn;% internal LUKE time step. As an imaginary number, dkeparam.dtn prescribes the number of internal time steps
end
%
dkeparam.Nfluct = Nfluct;% Ratio of the LUKE evolution time (phase refresh) to the fluctuation time - also equal to the number of duplicated rays
equil.fluct.ne.sigmar_max = sigmar_max;% Maximum value of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
equil.fluct.ne.sigmar_hwhm = sigmar_hwhm;%Radial half width at half maximum of the relative fluctuations variance at the poloidal angle theta = 0 [1,nfluct_types]
%
id_simul = [id_simul,'_sigma',num2str(sigmar_max),'_delta',num2str(sigmar_hwhm),'_dtn',num2str(dtn),'_Nfluct',num2str(Nfluct)];
id_simul(id_simul == '.') = 'p';
id_simul(id_simul == '+') = 'p';
%
lukestructs = rmfield(lukestructs,'id_simul');
lukestructs.simul.id = id_simul;
lukestructs.simul.path = path_simul;
lukestructs.equil = equil;
lukestructs.dkeparam = dkeparam;
lukestructs.opt.save = 1;% to save result in file
lukestructs.opt.backup = opt_save;% backup option with fluctuations
lukestructs.opt.waves = 1;% save wave results with fluctuations
%
run_lukert(lukestructs,dkepath);
%
