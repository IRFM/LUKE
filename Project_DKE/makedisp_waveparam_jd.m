function makedisp_waveparam_jd(omega,xrho,xtheta,xNpar);

if length(xrho) == 1
    data = repmat([xrho;xtheta;xNpar],[1,2]);
else
    data = [xrho;xtheta;xNpar];
end

s_omega = smat2f_jd(sprintf('%d',omega/2/pi));
s_data = smat2f_jd(sprintf('%d,%d,%d\n',data));

savestr = ['waveparam.m'];
delete(savestr);

fid = fopen(savestr,'w');
fprintf(fid,'%s\n',s_omega);
fprintf(fid,'%s',s_data);
fprintf(fid,'%s','-1');
fclose(fid);


