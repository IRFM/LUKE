% Cette fonction lance script_dke_1yp.m en mode batch sur deneb.cad.cea.fr
%  
% syntaxe  :
%  
%    cr = dke_batch_yp(machine,queue);
%      
% entrees :
%               
%    machine =  machine sur laquel le job est execute 
%               (par defaut la machine d'ou est lancee 
%               la commande)
%               
%    queue   =  file d'attente du job (par defaut "nuit") 
%    
% sorties :
% 
%     cr         =  compte rendu d'execution
%    
% fonction ecrite par J-F Artaud , poste 46-78
% modifiee par Y.Peysson 03/10/2004 pour DKE
%
%--------------------------------------------------------------
%
function cr = dke_batch_yp(job,name,machine,queue)

clc

% initialisation de cr
cr    = 0;



if nargin <2
	job =1;
end

if nargin <2
	name ='peysson';
end

if nargin <3
	machine ='';
end

if isempty(machine)
	[s,t]=unix('uname -n');
	ind = min(find(t =='.'));
	if isempty(ind)
		machine = t;
	else
		machine = t(1:(ind-1));
	end
end

if nargin <4
	queue ='nuit';
elseif isempty(queue)
	queue ='nuit';
end
	
root = '/usr/drfc/peysson/Project_DKE/';

% effacement du fichier de trace 
[s,t] =unix(['rm ','BATCH_DKE','.log']);

nom_err  = strcat(root,'BATCH_DKE.out');
nom_info  = strcat(root,'BATCH_DKE.info');
nom_exec = strcat(root,'BATCH_DKE.exe');

% effacement du fichier err s'il existe
[s,t]=unix(['rm ',nom_err,' >& /dev/null']);

% le modele
crs=sprintf('\n');
modele = ['#!/bin/csh',crs, ...
	     'unsetenv DISPLAY',crs, ...
	     'pwd',crs, ...
	     'matlab <<@@ > /dev/null ',crs, ...
	     'cd /usr/drfc/peysson/Project_DKE',crs, ...
	     'script_dke_1yp(',job,')',crs, ...
	     'exit',crs, ...
	     '@@',crs, ...
	     'exit',crs];

% ecriture du fichier executable
fid = fopen(nom_exec,'w');
if fid <3 
	disp('Probleme d''ouverture du fichier executable')
	disp(lasterr)
	cr =-19001;
	return
end
fprintf(fid,modele);
fclose(fid);

% changement de mode
[s,t] = unix(['chmod a+x ',nom_exec]);
if s ~= 0 
	disp('Le fichier ne peut etre rendu executable')
	disp(t)
	cr =-19002;
	return
end


  % creation du fichier job
   [pf,nf,ef] = fileparts(nom_exec);
    nom_job    = fullfile(pf,strcat(nf,'.job'));
    % ouverture du fichier
   fid = fopen(nom_job,'w');
   if fid <3 
	   disp('Probleme d''ouverture du fichier job pour loadleveler')
	   disp(lasterr)
	   cr =-19127;
	   return
   end
   % ecriture
   ordi = 'deneb.cad.cea.fr';
   [pf,ff] = fileparts(nom_err);
   fprintf(fid,'#!/bin/sh\n');
   fprintf(fid,'#PBS -N %s\n',ff(1:min(length(ff),15)));
   fprintf(fid,'#PBS -o %s\n',pf);
   fprintf(fid,'#PBS -e %s\n',pf);
   fprintf(fid,'#PBS -j oe\n');
   fprintf(fid,'#PBS -q %s\n',queue);
%   fprintf(fid,'#PBS -l host=%s\n',ordi);
   fprintf(fid,'#PBS -m be\n');
   fprintf(fid,'#PBS -M %s\n',name);
   fprintf(fid,'#PBS -r n\n');
   fprintf(fid,'#PBS -V\n');
   fprintf(fid,'PBS_O_WORKDIR="%s"\n',root);
   fprintf(fid,'export PBS_O_WORKDIR\n');
   fprintf(fid,'%s\n',nom_exec);
   fprintf(fid,'  \n');
   fclose(fid);

   % changement de mode
   [s,t] = unix(['chmod a+x ',nom_job]);
   if s ~= 0 
	   disp('Le fichier ne peut etre rendu executable')
	   disp(t)
	   cr =-19229;
	   return
   end
   
   % envoie de la commande batch
   commande = sprintf('qsub %s',nom_job);
   [s,t]    = unix(commande);
   if s ~= 0 
	  disp('soumission du job impossible !')
	  disp(t)
	  cr =-19003;
	   return
   else   
	jobid = strtok(t,'.'); 
	try
		delete(nom_info);
	 catch
		 % rien
	 end
      nomlog = 'BATCH_DKE.log';
		disp('Job soumis via qsub:');
		fprintf('%s via qsub %s avec la reference %s\n',nom_exec,nom_job,t)
		disp('   ')
		disp('-----------------')
		diary(nom_info)
		disp('informations utiles :')
		fprintf('Pour suivre l''execution du job, sous unix, tapez "qstat %s"\n',jobid);
		fprintf('Pour tuer le job, sous unix, tapez "qdel %s"\n',jobid);
		fprintf('Pour voir le rapport de qsub, sous unix, tapez "cat %s/%s.*.OU"\n',pf,jobid);
		fprintf('Pour surveiller l''execution via le logfile taper, sous unix :\n');
		fprintf('tail -f %s\n',nomlog);
		fprintf('(rem: le pid du traitement est note en tete de ce fichier)\n');
		diary off
		disp('-----------------')
		fprintf('=> retrouver ces informations dans %s\n',nom_info);

end
		
		
		
if nargout == 0
	clear cr
end