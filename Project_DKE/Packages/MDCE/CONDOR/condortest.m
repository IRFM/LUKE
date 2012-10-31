function condortest(sleepnumber,sleepinterval,filename)
%
%   Matlab function for testing the CONDOR scheduling environment
% 
%   by Y. Peysson (CEA/DSM/IRFM,yves.peysson@cea.fr) and J. Decker (CEA/DSM/IRFM,joan.decker@cea.fr)
%
fid = fopen( filename, 'w' );
%
fprintf( fid, 'Running condortest.m, with sleepinterval=%i seconds and sleepnumber=%i ...\n', sleepinterval, sleepnumber);
%
for i=1:sleepnumber
	fprintf( fid, 'Iteration %i....\n', i);
	pause(sleepinterval);
end;
%
fclose(fid)
%
quit;
