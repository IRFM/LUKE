function [status,result] = write_launchs_ITM(waveparam,launch,numshot,numrun,time)
%LUKE - Function that writes a C3PO launchs structure into ITM MDS+ database using the CPO format
%
%Function that writes a C3PO launchs  structure into ITM MDS+ database using the CPO format
%
%by Y.Peysson CEA-IRFM <yves.peysson@cea.fr> and Joan Decker CEA-IRFM (joan.decker@cea.fr)
%
if nargin < 5,error('Not enough input arguments in write_launchs_ITM.m');end
if nargin == 5,
	time = [0];%Only one default time slice is written in the ITM MDS+ database 
end
%
status = 0;
result = '';
[qe,me,mp,mn,e0,mu0,re,mc2,clum] = pc_dke_yp;
%
import ualmemory.javainterface.*;
%
ntime = length(time);
%
try,
	expIdx = openBD('euitm',numshot,numrun);%Open the database
	equil = CPO_get(expIdx,'equilibrium');%Read magnetic equilibrium
	closeBD(expIdx,'euitm',numshot,numrun);	
	%
	Rgeo = equil.eqgeometry.geom_axis.r;
	Zgeo = equil.eqgeometry.geom_axis.z;
	if isinf(Rgeo),
		status = -1;
		result = 'WARNING: C3PO launchs structure incompatible with infinite major radius, i.e. cylindrical geometrical configuration.';
		return
	end
	%
	expIdx = UALAccess.create('euitm',numshot,numrun,numshot,0);
	launchCPO = CPO_create('launchs',ntime);
	%
	for it = 1:ntime,
		%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 'launchs' CPO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%
		% datainfo element
		%
		launchCPO(it).datainfo.dataprovider = 'Yves Peysson & Joan Decker, CEA/DSM/IRFM';
		launchCPO(it).datainfo.putdate = date;
		launchCPO(it).datainfo.source = 'LUKE package';
		launchCPO(it).datainfo.comment = 'For validation use';
		launchCPO(it).datainfo.isref = 0;
		launchCPO(it).datainfo.whatref.user = 'C3PO code';
		launchCPO(it).datainfo.whatref.machine = '';
		launchCPO(it).datainfo.whatref.shot = numshot;
		launchCPO(it).datainfo.whatref.run = numrun;
%		launchCPO(it).datainfo.whatref.occurence = 0;
		%
		launchCPO(it).name = launch.id;
		launchCPO(it).type = launch.type;
		launchCPO(it).frequency = launch.omega_rf/2/pi;
		%		
		launchCPO(it).mode = waveparam.mmode;
		%
		if strcmp(launch.type,'EC'),
			%	
			r = sqrt((launch.yR_L - equil.eqgeometry.geom_axis.r)^2 +(launch.yZ_L - equil.eqgeometry.geom_axis.z)^2);
			if 	launch.yR_L == equil.eqgeometry.geom_axis.r, 
				if launch.yZ_L - equil.eqgeometry.geom_axis.z > 0
					theta = pi/2;
				else
					theta = -pi/2;
				end
				%
				theta = atan((launch.yZ_L - equil.eqgeometry.geom_axis.z)/(launch.yR_L - equil.eqgeometry.geom_axis.r)) + pi - pi*((launch.yR_L - equil.eqgeometry.geom_axis.r) > 0).*sign(launch.yZ_L - equil.eqgeometry.geom_axis.z);%poloidal angle [0,2*pi]	
			end
			%
			launchCPO(it).position.r = launch.yR_L;
			launchCPO(it).position.z = launch.yZ_L;
			launchCPO(it).position.phi = -launch.yphi_L;
			launchCPO(it).spectrum.nn_phi = 1;
			launchCPO(it).spectrum.nn_theta = 1;
			launchCPO(it).spectrum.n_phi = sin(launch.ybeta_L)*sin(launch.yalpha_L)*launch.omega_rf*launch.yR_L/clum;
			launchCPO(it).spectrum.n_theta = (cos(theta)*cos(launch.ybeta_L) - sin(launch.ybeta_L)*cos(launch.yalpha_L)*sin(theta))*launch.omega_rf*r/clum;
			launchCPO(it).spectrum.power = launch.yP_L;
			if isfield(launch,'w0'),
				launchCPO(it).beam.spot.waist = launch.w0;
			else
				launchCPO(it).beam.spot.waist = '';			
			end
			launchCPO(it).beam.spot.angle = '';
			launchCPO(it).beam.phaseellipse.invcurvrad = '';
			launchCPO(it).beam.phaseellipse.angle = '';	
		elseif strcmp(launch.type,'LH')
			launchCPO(it).position.r = '';
			launchCPO(it).position.z = launch.rZ0;
			launchCPO(it).position.phi = '';
			launchCPO(it).spectrum.nn_phi = '';
			launchCPO(it).spectrum.nn_theta = '';
			launchCPO(it).spectrum.n_phi = '';
			launchCPO(it).spectrum.n_theta = '';
			launchCPO(it).spectrum.power = '';
			launchCPO(it).beam.spot.waist = '';
			launchCPO(it).beam.spot.angle = '';
			launchCPO(it).beam.phaseellipse.invcurvrad = '';
			launchCPO(it).beam.phaseellipse.angle = '';	
		else
			error('Error of wave type');		
		end		
		%
		% codeparam element
		%
		launchCPO(it).codeparam.codename ='C3PO';		
		launchCPO(it).codeparam.codeversion = [LUKEversion_jd,' - MATLAB ',version];		
		launchCPO(it).codeparam.parameters = '';		
		launchCPO(it).codeparam.output_diag = '';		
		launchCPO(it).codeparam.output_flag = 0;		
		%
		% time element
		%
		launchCPO(it).time = time(it);
	end
	%
	CPO_put(expIdx,launchCPO);
	closeBD(expIdx,'euitm',numshot,numrun);
catch
	status = -1;
	result = 'WARNING: C3PO launchs unsuccessfully writen in the ITM-MDS+ database.';
end
%









