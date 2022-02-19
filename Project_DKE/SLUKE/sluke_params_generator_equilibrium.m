function sparams = sluke_params_generator_equilibrium(sparams)
%
%
% LUKE - Generator of parameters structure for sluke calculations (equilibrium). All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT :
%
%   - varargin : none (interactive mode), string (preset parameters) or 'sparams' structure for modifications
%
% OUTPUT :
%
%   - sparams : structure of parameters for sluke calculations.
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin == 0
    %
    error('Wrong number of input arguments in sluke_params_generator_equilibrium.')
    %
elseif nargin == 1
    %
    if isstruct(sparams) 
        %
        if isfield(sparams,'machine') && isfield(sparams,'discharge') 
            %
            for ii = 1:length(sparams.machine)
                %
                disp([' - Toroidal MHD equilibrium parameters for discharge ', int2str(ii),'/',int2str(length(sparams.machine)),' (tokamak :',sparams.machine{ii},')']);
                %
%{
%}
  %}              
                
                
                
                
                
                
                
                
                
                
                
                
                if ii > 1
                    %
                    sparams.equil.comment{ii} = input_dke_yp('   - comment for the toroidal MHD equilibrium parameters : ',sparams.equil.comment{ii-1});%comments on the toroidal MHD equilibrium parameters
                    %  
                    sparams.equil.source{ii} = input_dke_yp('   - source of the toroidal MHD equilibrium parameters [code, file or value]',sparams.equil.source{ii-1},{'code','file','value'});%source of the toroidal MHD equilibrium parameters : 'code', 'file'
                    %
                    if strcmp(sparams.equil.source{ii},'code')
                        %
                        sparams.equil.code{ii} = input_dke_yp('   - name of the code for calculating the toroidal MHD equilibrium parameters [metis, feeqs, helena]',sparams.equil.code{ii-1},{'metis','feeqs','helena'});%code name for determining the toroidal MHD equilibrium parameters : 'metis',... (used if source.method is 'code')
                        %
                    elseif strcmp(sparams.equil.source{ii},'file')
                        %
                        sparams.equil.file{ii} = input_dke_yp('   - name of the file that contains the toroidal MHD equilibrium parameters : ',sparams.equil.file{ii-1});%full path of the file that contains the toroidal MHD equilibrium parameters (used if source.method is 'file')
                        sparams.equil.path{ii} = input_dke_yp('   - full or local (.) path of the file that contains the toroidal MHD equilibrium parameters : ',sparams.equil.file{ii-1});%full path of the file that contains the toroidal MHD equilibrium parameters (used if source.method is 'file')
                        %
                    end
                else
                    %
                    sparams.equil.comment{ii} = input_dke_yp('   - comment for the toroidal MHD equilibrium parameters : ','');%comments on the toroidal MHD equilibrium parameters
                    %  
                    sparams.equil.source{ii} = input_dke_yp('   - source of the toroidal MHD equilibrium parameters [code, file or value]','code',{'code','file','value'});%source of the toroidal MHD equilibrium parameters : 'code', 'file'
                    %
                    if strcmp(sparams.equil.source{ii},'code')
                        %
                        sparams.equil.code{ii} = input_dke_yp('   - name of the code for calculating the toroidal MHD equilibrium parameters [metis, feeqs, helena]','metis',{'metis','feeqs','helena'});%code name for determining the toroidal MHD equilibrium parameters : 'metis',... (used if source.method is 'code')
                        %
                    elseif strcmp(sparams.equil.source{ii},'file')
                        %
                        sparams.equil.file{ii} = input_dke_yp('   - name of the file that contains the toroidal MHD equilibrium parameters : ','');%full path of the file that contains the toroidal MHD equilibrium parameters (used if source.method is 'file')
                        sparams.equil.path{ii} = input_dke_yp('   - full or local (.) path of the file that contains the toroidal MHD equilibrium parameters : ','.');%full path of the file that contains the toroidal MHD equilibrium parameters (used if source.method is 'file')
                        %
                    end  
                    %
                end
                %
                sparams.equil.equilconsistency.comment{ii} = input_dke_yp('   - comment for the consistency calculation of the toroidal MHD equilibrium','');
                %
                sparams.equil.equilconsistency.auto_mode{ii} = input_dke_yp('   - auto mode for the consistency calculation of the toroidal MHD equilibrium [0,1]',1,[0,1]);
                %
                sparams.equil.equilconsistency.display_mode{ii} = input_dke_yp('   - display mode for the consistency calculation of the toroidal MHD equilibrium [0,1]',0,[0,1]);
                %
                sparams.equil.equilconsistency.prho{ii} = input_dke_yp('   - number of radial positions for the consistency calculation of the toroidal MHD equilibrium (empty is automatic mode)',[]);
                %
                sparams.equil.equilconsistency.mtheta{ii} = input_dke_yp('   - number of poloidal angles for the consistency calculation of the toroidal MHD equilibrium (empty is automatic mode)',[]);
                %
                sparams.equil.fit.comment{ii} = input_dke_yp('   - comment for the fit of the toroidal MHD equilibrium','');
                %
                sparams.equil.fit.mode_equil{ii} = input_dke_yp('   - equil type for the fit of the toroidal MHD equilibrium [1->(rho,theta),2->(x,y)]',1,[1,2]);
                %
                sparams.equil.fit.method{ii} = input_dke_yp('   - interpolation method for the fit of the toroidal MHD equilibrium [spline, pchip]','spline',{'spline','pchip'});
                %
                sparams.equil.fit.nharm{ii} = input_dke_yp('   - Number of harmonics for the fit of the toroidal MHD equilibrium [NaN : automatic mode]',NaN);
                %
                sparams.equil.fit.ngridresample{ii} = input_dke_yp('   - Number of gris points for radial grid resmpling for the fit of the toroidal MHD equilibrium',1001);
                %
                sparams.equil.fit.opt_load{ii} = 0;
                %{
                sparams.equil.ripple.comment{ii} = {'','',''};
                sparams.equil.ripple.source{ii} = {'','',''};
                sparams.equil.ripple.preset{ii} = {'','',''};
                sparams.equil.ripple.file{ii} = {'','',''};
                sparams.equil.ripple.path{ii} = {'','',''};
                sparams.equil.ripple.mode{ii} = {0,0,0};%(0): non magnetic ripple, (1) with toroidal magnetic ripple. For Tore Supra or WEST tokamaks only yet
                %}
                disp('------------------------------------------------------------------');
                %
            end
            %
            disp('------------------------------------------------------------------');
            %
            sparams = sluke_params_generator_equilconsistencyparam(sparams);% Interactive mode : parameters for checking the consistency of the toroidal MHD equilibrium. Calculate some additional useful quantities.
            %
        else
            %
            error('Wrong type of input arguments in sluke_params_generator_equilibrium. Run sluke_params_generator_discharge first and use sparams as input.')
            %
        end
        %
    else
        %
        error('Wrong type of input arguments in sluke_params_generator_equilibrium. Run sluke_params_generator_discharge first and use sparams as input.')
        %
    end
    %
end