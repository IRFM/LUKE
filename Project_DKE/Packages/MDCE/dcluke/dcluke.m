function varargout = dcluke(dkecluster,entree1,varargin)
% LUKE - LUKE distributed computing environment
%
% dcluke fonction feval distribuee
%------------------------------------------------------------------------------- 
% file :  dcluke.m  ->   dcluke
% 
% 
% function Matlab 7 : 
% 
% cette fonction permet d'appeler des fonction matlab en distribuant le calcul 
% sur differentes machines via le systeme de batch. L'appel est similaire a feval.
%
%
% syntaxe :  
%
%  appel d'une fonction distribue
%   
%    id = dcluke(dkecluster,'nom_fonction',entree1, ...,entreen);
%
%  attente de la fin des jobs :
%   
%   dcluke;
%
%  lecture resultat :
%
%   [sortie1,...,sortien] = dcluke(dkecluster,id);
%
%  arreter un job :
%
%    dcluke(dkecluster,id,'KILL')
% 
%  arreter tous les jobs :
%    
%    dcluke(dkecluster,0,'KILL')
%
%  information sur un job :
%
%   info =  dcluke(dkecluster,id,'INFO')
%
%  information sur tous les jobs :
%
%   info =  dcluke(dkecluster,0,'INFO')
%
%  fin de tous les jobs et reset du systeme :
%
%   dcluke(dkecluster,0,'RESET')
% 
% input : 
%
%		dkecluster       : cluster parameters
%      'nom_fonction' :      nom de la fonction 
%      entree1..entreen :    variables d'entrees de la fonction
%      id  :                 numero d'identification du job
%  
% sorties :
%	
%      id  :                 numero d'identification du job
%      sortie1..sortien :    sorties de la fonction
%      info :                structure d'informations du job
%
% fichiers a configurer sous architecture:
%
%  dcluke_etat.sh  -> retourne l'etat d'un job 
%  dcluke_kill.sh  -> arrete un job 
%  dcluke_batch.sh -> lance un job
%  dcluke.exe      -> execute un matlab distribue
%
% autres fonctions utiles :
%  testdcluke.m      -> fonction de test
%  
% remarque : la session courante est sauve dans un dossier dossier cr?? dans pcluke.temppathroot (voir make_path_LOCAL.m suivant la machine)
% ce mecanisme ne permet uniquement a une seule session pour un meme user de redemarrer apres etre sortie de matlab.
%  
% function initially writen by J-F Artaud, tel 62-15  and modified by Y. Peysson for LUKE
%  
%-------------------------------------------------------------------------------  
%  
% recuperation variable environnement
%
dcluke_display = dkecluster.display;
workdir  = dkecluster.temppath;
%
% donnees
%
if isappdata(0,'BATCH_DISTRIBUE_LUKE')
	ba = getappdata(0','BATCH_DISTRIBUE_LUKE');
elseif exist([workdir,'.dcluke.mat'],'file');
	ba =struct([]);
	warning off
	load([workdir,'.dcluke.mat']);
	warning on
else
	ba = struct([]);
end
% commande de lancement et de controle des jobs
cmd.run   = which('dcluke_batch.sh');
cmd.state = which('dcluke_etat.sh');
cmd.kill  = which('dcluke_kill.sh');
% pas de sortie par defaut
varargout = {};
%
% le mode depend des entrees
%
if nargin == 1,
	% test des etats et attente
	attente = 1;
	while	(attente == 1)
		attente = 0;
		% mise a jour des etat
		for k = 1:length(ba)
			switch ba(k).etat 
			case 'running'
				[s,t] = unix(sprintf('%s %d',cmd.state,ba(k).jobid));
				if s ~= 0
					ba(k).etat ='done';	
					if dcluke_display,
						fprintf('dcluke: job %d terminated (%d)\n',k,ba(k).jobid);
					end
				else
					attente = 1;
					pause(0.1);
				end
			end
		end
	end
%
%TODO: Probleme lié au montage NFS tres lent de CEPHEE. A enlever plus tard...
%
	[hostname] = unix('hostname');
	if strfind(hostname,'cephee'),
		pause(10);
	end
elseif nargin > 1 & isstr(entree1),
	% id du job
	current = length(ba) +1;	
	% rempplissage de la structure
	% commande
	ba(current).commande = entree1;
	% donnees de la commande
	%ba(current).entrees   = varargin;
	% chemin matlab
	%ba(current).path     = path;
	% parametre de l'application
	%ba(current).appdata  = getappdata(0);
	% repertoire d'execution
	ba(current).dir      = pwd;
	% fichier journal
	ba(current).diaryfile   = fullfile(workdir,sprintf('diary_dcluke_%d.txt',current));
	% fichier des resultats
	ba(current).outputdata   = fullfile(workdir,sprintf('output_dcluke_%d.mat',current));
	% fichier de lencement du batch
	ba(current).batchfile   = fullfile(workdir,sprintf('batch_dcluke_%d',current));
	% fichier de lencement du batch
	ba(current).batchout   = fullfile(workdir,sprintf('zd%d.o*',current));
	% etat du run
	ba(current).etat  = 'prepare';
	% sortie en erreur
	ba(current).etat_sortie  = 1;
	% message d'erreur
	ba(current).error  = '';
	% texte ecrit pendant le run
	%ba(current).diary  = '';
	% resultat
	%ba(current).resultat  = {};
	
	% appel equivalent a feval
	% sauvegarde des donnees
	ba(current).inputdata   = fullfile(workdir,sprintf('input_dcluke_%d.mat',current));
	data                    = ba(current);
	data.entrees            = varargin;
	data.path               = path;
	data.appdata            = getappdata(0);
	data.resultat           = {};
	save(ba(current).inputdata,'data');
	% lancement du job
	script = which('dcluke.exe');
	txt =   sprintf('%s %s zd%d %s %s %s %s', cmd.run,workdir,current,getenv('USER'),script,ba(current).inputdata,ba(current).batchfile);
	[s,t] = unix(txt);
	if s~= 0
			error(sprintf('dcluke : error launching job %d in batch :\n %s',entree1,t));				
	else
		[v,r] = strtok(t);
		[v,r] = strtok(r);
		[v,r] = strtok(r);
		ba(current).jobid = str2num(v);	
		ba(current).etat  = 'running';
	end
	varargout{1} = current;
elseif nargin == 2,
	% lecture du resultat pour la reference donnees
	if length(ba) >= entree1
		switch ba(entree1).etat 
		case 'running'
			[s,t] = unix(sprintf('%s %d',cmd.state,ba(entree1).jobid));
			if s ~= 0
				ba(entree1).etat ='done';	
			end
		end
		% test de fin
		switch ba(entree1).etat 
		case  'done'
			% lecture du resultat
			try 
				data = load(ba(entree1).outputdata);
			catch
				if exist(ba(entree1).diaryfile,'file')
					type(ba(entree1).diaryfile)
				end
				error(sprintf('dcluke : error loading result job %d',entree1));			
			end
			% lecture du texte
			%ba(entree1).resultat = data.resultat;
			ba(entree1).etat_sortie = data.etat_sortie;
			ba(entree1).error = data.etat_error;
			if ba(entree1).etat_sortie == 1
				error(sprintf('dcluke : error in "%s" :\n %s',ba(entree1).commande,ba(entree1).error));
			end
			varargout = data.resultat;
			% destruction du resultat
			warning off
			delete(ba(entree1).diaryfile);
			delete(ba(entree1).inputdata);
			delete(ba(entree1).outputdata);
			delete(ba(entree1).batchfile);
			delete(ba(entree1).batchout);
			warning on
			ba(entree1).etat = 'delete';
		case 'delete'
			warning('dcluke : job %d results had already been read',entree1);
			[varargout{1:nargout}] = deal([]);
		otherwise
			warning('dcluke : job %d is not finish',entree1);
			[varargout{1:nargout}] = deal([]);
		end
	end
else
	if entree1 == 0
		% test des etats et attente
		attente = 1;
		while	(attente == 1)
			attente = 0;
			% mise a jour des etat
			for k = 1:length(ba)
				switch ba(k).etat 
				case 'running'
					[s,t] = unix(sprintf('%s %d',cmd.state,ba(k).jobid));
					if s ~= 0
						ba(k).etat ='done';	
					end
				end
			end
		end
	else
		switch ba(entree1).etat 
		case 'running'
			[s,t] = unix(sprintf('%s %d',cmd.state,ba(entree1).jobid));
			if s ~= 0
				ba(entree1).etat ='done';	
			end
		end
	end
	
	switch varargin{1}
	case 'KILL'
		if entree1 == 0
			for k = 1:length(ba)
				switch ba(k).etat 
				case 'running';
					[s,t] = unix(sprintf('% %d',cmd.kill,ba(k).jobid));
					% destruction du resultat
					warning off
					delete(ba(k).diaryfile);
					delete(ba(k).inputdata);
					delete(ba(k).outputdata);
					delete(ba(k).batchfile);
					delete(ba(k).batchout);
					warning on
					ba(k).jobid = NaN;
					ba(k).etat ='delete';
				case 'delete'
					%rien
				otherwise
					warning off
					delete(ba(k).diaryfile);
					delete(ba(k).inputdata);
					delete(ba(k).outputdata);
					delete(ba(k).batchfile);
					delete(ba(k).batchout);
					warning on
					ba(k).jobid = NaN;
					ba(k).etat ='delete';					
				end	
			end	
		elseif length(ba) >= entree1 
			% fin du job					
			switch ba(entree1).etat 
			case 'running'
				[s,t] = unix(sprintf('% %d',cmd.kill,ba(entree1).jobid));
				if s == 0
					ba(entree1).jobid = NaN;
					% destruction des fichiers 
					warning off
					delete(ba(entree1).diaryfile);
					delete(ba(entree1).inputdata);
					delete(ba(entree1).outputdata);
					delete(ba(entree1).batchfile);	 
					delete(ba(entree1).batchout);
					warning on
					ba(entree1).etat ='delete';							
				else
					error(sprintf('dcluke : unable to delete job %',ba(entree1).jobid));
				end
			case 'delete'
				%rien
			otherwise
				ba(entree1).jobid = NaN;
				% destruction des fichiers 
				warning off
				delete(ba(entree1).diaryfile);
				delete(ba(entree1).inputdata);
				delete(ba(entree1).outputdata);
				delete(ba(entree1).batchfile);	 
				delete(ba(entree1).batchout);
				warning on
				ba(entree1).etat ='delete';
										
			end
		end
	case 'INFO'
		if entree1 == 0
			varargout{1} =	ba
		else
			varargout{1} =	ba(entree1)		
		end	
	case 'RESET'
		dcluke(dkecluster,0,'KILL')
		ba = struct([]);
	end
	
end

setappdata(0,'BATCH_DISTRIBUE_LUKE',ba);	
save([workdir,'.dcluke.mat'],'ba');
