function makedisp_tokparam_jd(tokamak);

loadstr = ['PARAM_',tokamak,'.mat'];
eval(['load ',loadstr]);

Te0 = max(pTe);
ne0 = max(pne);

% distances in cm, B-field in Gauss, Current in Amps
param1 = [Rp*1e2 ap*1e2 Bt*1e4 Ip*1e6];
% temperature in eV, density in cm-3
param2 = [Te0*1e3 ne0*1e-6];
data = [prho;pTe/Te0;pne/ne0;pq];

s_param1 = smat2f_jd(sprintf('%d,%d,%d,%d',param1));
s_param2 = smat2f_jd(sprintf('%d,%d',param2));
s_data = smat2f_jd(sprintf('%d,%d,%d,%d\n',data));

savestr = ['PARAM_',tokamak,'.m'];
delete(savestr);

fid = fopen(savestr,'w');
fprintf(fid,'%s\n',s_param1);
fprintf(fid,'%s\n',s_param2);
fprintf(fid,'%s',s_data);
fprintf(fid,'%s','-1');
fclose(fid);


