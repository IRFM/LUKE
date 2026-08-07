% /////////////////////////////////////////
%
% Software name : LUKE
%
% Authors : Yves Savoye-Peysson and Joan Decker
%
% Copyright holders : Commissariat a l'Energie Atomique et aux Energies Alternatives (CEA), France
%
% CEA authorizes the use of the LUKE software under the CeCILL-C open source license https://cecill.info/licences/Licence_CeCILL-C_V1-en.html
%
% The terms and conditions of the CeCILL-C license are deemed to be accepted upon downloading the software and/or exercising any of the rights granted under the CeCILL-C license.
%
% /////////////////////////////////////////
%
function sparams = sluke_params_generator_discharge(sparams)
%
%
% LUKE - Generator of parameters structure for sluke calculations (discharge). All parameters are in a structure of cell arrays of the SAME SIZE. 
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
    error('Wrong number of input arguments in sluke_params_generator_discharge.')
    %
elseif nargin == 1
    %
    sparams = struct;
    %
    % Interactive mode for buiding sparams
    %
    disp('------------------------------------------------------------------');
    disp('------------------------------------------------------------------');
    disp('Interactive input of simulation parameters for sluke calculations');
    disp('------------------------------------------------------------------');
    disp('------------------------------------------------------------------');
    ntoks = input_dke_yp('Number of tokamaks',1);
    disp('------------------------------------------------------------------');
    %
    for itok = 1:ntoks
        %
        tokname{itok} = input_dke_yp(['Name of tokamak #',int2str(itok),'/#',int2str(ntoks),' (TS,WEST,EAST,CMOD,ITER,HL2A,TOK)'],'WEST',{'TS','WEST','EAST','CMOD','ITER','TOK'});
        %
        ndischarges(itok) = input_dke_yp(['Number of discharges (as many as time intervals) for tokamak ',tokname{itok}],1);
        %
        disp('------------------------------------------------------------------');
        %
        for jdischarge = 1:ndischarges(itok)
            %
            disp([' - Discharge ',int2str(jdischarge),'/',int2str(ndischarges(itok)),' for tokamak ',tokname{itok}]);
            %
            if jdischarge > 1
                discharge{itok,jdischarge} = input_dke_yp('   - shot number',discharge{itok,jdischarge-1});
            else
                discharge{itok,jdischarge} = input_dke_yp('   - shot number','');
            end
            %
            if jdischarge > 1
                tmin(itok,jdischarge) = input_dke_yp('   - tmin (s)',tmin(itok,jdischarge-1));
            else
                tmin(itok,jdischarge) = input_dke_yp('   - tmin (s)',0);
            end
            %
            if jdischarge > 1
                while 1
                    tmax(itok,jdischarge) = input_dke_yp('   - tmax (s)',tmax(itok,jdischarge-1));
                    if tmax(itok,jdischarge) >= tmin(itok,jdischarge)
                        break
                    else
                        disp(['WARNING : tmax should greater or equal to tmin = ',num2str(tmin(itok,jdischarge))])
                    end
                end
            else
                while 1
                    tmax(itok,jdischarge) = input_dke_yp('   - tmax (s)',0);
                    if tmax(itok,jdischarge) >= tmin(itok,jdischarge)
                        break
                    else
                        disp(['WARNING : tmax should greater or equal to tmin = ',num2str(tmin(itok,jdischarge))])
                    end
                end
            end
            %
            nt(itok,jdischarge) = input_dke_yp('  - Number of time subintervals between tmin and tmax (max = 100)',1,[1:100]);
            %
            disp('------------------------------------------------------------------');
        end
        %
        disp('------------------------------------------------------------------');
        %
    end
    %
    % MACHINES (TOKAMAK)
    %
    for itok = 1:ntoks
        %
        for jdischarge = 1:ndischarges(itok)
            %
            if itok == 1 && jdischarge == 1
                %
                sparams.machine{1} = tokname{1};
                %
            else
                %
                sparams.machine = [sparams.machine,{tokname{itok}}];
                %
            end
        end
        %
    end
    %
    % DISCHARGES
    %
    for itok = 1:ntoks
        %
        for jdischarge = 1:ndischarges(itok)
            %
            if itok == 1 && jdischarge == 1
                %
                sparams.discharge.shot{1} = discharge{1,1};%shot number
                sparams.discharge.tmin{1} = tmin(1,1);
                sparams.discharge.tmax{1} = tmax(1,1);
                sparams.discharge.nt{1} = nt(1,1);
                %
            else
                %
                sparams.discharge.shot = [sparams.discharge.shot,{discharge{itok,jdischarge}}];
                sparams.discharge.tmin = [sparams.discharge.tmin,{tmin(itok,jdischarge)}];
                sparams.discharge.tmax = [sparams.discharge.tmax,{tmax(itok,jdischarge)}];
                sparams.discharge.nt = [sparams.discharge.nt,{nt(itok,jdischarge)}];
                %
            end
        end
        %
    end
    %
end