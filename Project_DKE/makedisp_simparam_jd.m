function makedisp_simparam_jd(xpsin,xB,xTe,xne,xNpar,omega,knr,nrt_nr,nrt_fr,kflag,GNperp,nn_nr,tol_ht,nd_ht);
%
if nargin < 14
    nd_ht = 11;
end
if nargin < 13
    tol_ht = 0.2;
end
%
nr = length(xpsin) - 1;%-1 because the first point is read separately in R2D2
%
rtparam = [knr,nrt_nr,nrt_fr,tol_ht,nd_ht];
%
GNperpRe = real(GNperp);
GNperpIm = imag(GNperp);
%
bt0 = max(xB);
Te0 = max(xTe);
ne0 = max(xne);
param = [bt0*1e4,Te0*1e3,ne0*1e-6,omega/2/pi];
data = [xpsin;xTe/Te0;xne/ne0;xB/bt0;xNpar];
%
s_rparam = smat2f_jd(sprintf('%d',nr));
s_root = smat2f_jd(sprintf('%d,%d,%d,%d,%d',rtparam));
s_nterms = smat2f_jd(sprintf('%d',nn_nr));
s_kflag = smat2f_jd(sprintf('%d',kflag));
s_rootRe = smat2f_jd(sprintf('%d ',GNperpRe));
s_rootIm = smat2f_jd(sprintf('%d ',GNperpIm));
s_param = smat2f_jd(sprintf('%d,%d,%d,%d',param));
s_data = smat2f_jd(sprintf('%d,%d,%d,%d,%d\n',data));

savestr = ['simparam.m'];
delete(savestr);

fid = fopen(savestr,'w');
fprintf(fid,'%s\n',s_rparam);
fprintf(fid,'%s\n',s_root);
fprintf(fid,'%s\n',s_nterms);
fprintf(fid,'%s\n',s_kflag);
fprintf(fid,'%s\n',s_rootRe);
fprintf(fid,'%s\n',s_rootIm);
fprintf(fid,'%s\n',s_param);
fprintf(fid,'%s',s_data);
fclose(fid);
