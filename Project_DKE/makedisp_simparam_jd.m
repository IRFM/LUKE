function makedisp_simparam_jd(tokamak,xrho,rho0,knr,nrt_nr,nrt_fr,kflag,GNperp,nn_nr);

loadstr = ['PARAM_',tokamak,'.mat'];
eval(['load ',loadstr,' ap']);
apcm = ap*100; % distances in cm

i_0 = find(abs(xrho - rho0) == min(abs(xrho - rho0)));
nr = length(xrho);

dxrho = diff(xrho);
if isempty(dxrho)
    rparam = [xrho*apcm,0,1,0,0];
elseif (max(dxrho) - min(dxrho)) > eps
    error('radial steps must be equidistant')
else
    dxrho = dxrho(1);
    rparam = [(xrho(i_0))*apcm,dxrho*apcm,nr + 1 - i_0,dxrho*apcm,i_0];
end

rtparam = [knr,nrt_nr,nrt_fr];

GNperpRe = real(GNperp);
GNperpIm = imag(GNperp);

s_file = [tokamak];
s_rparam = smat2f_jd(sprintf('%d,%d,%d,%d,%d',rparam));
s_root = smat2f_jd(sprintf('%d,%d,%d',rtparam));
s_nterms = smat2f_jd(sprintf('%d',nn_nr));
s_kflag = smat2f_jd(sprintf('%d',kflag));
s_rootRe = smat2f_jd(sprintf('%d ',GNperpRe));
s_rootIm = smat2f_jd(sprintf('%d ',GNperpIm));

savestr = ['simparam.m'];
delete(savestr);

fid = fopen(savestr,'w');
fprintf(fid,'%s\n',s_file);
fprintf(fid,'%s\n',s_rparam);
fprintf(fid,'%s\n',s_root);
fprintf(fid,'%s\n',s_nterms);
fprintf(fid,'%s\n',s_kflag);
fprintf(fid,'%s\n',s_rootRe);
fprintf(fid,'%s\n',s_rootIm);
fclose(fid);


