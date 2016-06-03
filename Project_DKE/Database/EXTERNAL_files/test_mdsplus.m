%
%test access to MDS+ database remotely
%
mdsconnect('mdsplus.jet.efda.org');%JET
choc=84744;
%
[picrh,status]=mdsvalue(sprintf('_sig7=jet("ppf/ICRH/PTOT",%d)',choc));
[ticrh,status]=mdsvalue('dim_of(_sig7)');  picrh=picrh/1e6;
%
mdsdisconnect;
%
figure, plot(ticrh,picrh)
title('JET discharge #84744');
%
mdsconnect('202.127.204.42');%EAST
shot = 43326;
%               
mdsopen('pcs_EAST',shot);
%
Ip=mdsvalue('\pcrl01'); % plasma current
time=mdsvalue('dim_of(\pcrl01)'); 
%
mdsclose;
mdsdisconnect;
figure, plot(time,Ip,'o')
title('EAST discharge #43326');
