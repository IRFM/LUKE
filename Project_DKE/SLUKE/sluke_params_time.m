function sparams_out = sluke_params_time(varargin)
%
% LUKE - Build time evolution fields from simulation parameters structure for sluke calculations with sub-time intervals. All parameters are in a structure of cell arrays of the SAME SIZE. 
% 
% INPUT :
%
%   - varargin : initial 'sparams' structure for modifications
%
% OUTPUT :
%
%   - sparams : modified structure of parameters for sluke calculations.
%
% by Y.Peysson (CEA/DSM/IRFM) <yves.peysson@cea.fr>
%
if nargin == 1
    %
    sparams_in = varargin{1};
    %
else
    %
    error('Wrong number of input arguments in sluke_params_time function');
    %
end
%
[err,status] = sluke_params_consistency(sparams_in);
%
if err == 0
    %
    fns_in = fieldnamesr(sparams_in);
    ihelp = find(contains_yp(fns_in,'help'));
    if ~isempty(ihelp)
        fns = fns_in(1:ihelp(1)-1);
    else
        fns = fns_in;
    end
    %
    nf0 = length(sparams_in.machine);
    %
    for ii = 1:nf0
        %
        sparams_tmp = sluke_params_extract(sparams_in,ii);
        %
        if ~isfield(sparams_tmp.discharge,'nt')
            %
            disp('WARNING : initial sparams.discharge sub-structure has no ''nt'' field. nt = 1 enforced ')
            %
            nt = 1;
            %
        else
            %
            nt = sparams_tmp.discharge.nt{1};
            %
        end
        %
        tmin = sparams_tmp.discharge.tmin{1};
        tmax = sparams_tmp.discharge.tmax{1};
        %
        dt = diff(linspace(tmin,tmax,nt+1));
        %
        if nt > 1
            simul_id = sparams_tmp.simul.id{1};
            sparams_tmp.simul.id = {[simul_id,'_1']};
        end
        sparams_tmp.discharge.tmin = {tmin};
        sparams_tmp.discharge.tmax = {tmin + dt(1)};
        sparams_tmp.discharge.nt = {1};
        %
        for jj = 2:nt
            %
            sparams_tmp = sluke_params_clone(sparams_tmp,1,1);
            %
            sparams_tmp.simul.id(jj) = {[simul_id,'_',int2str(jj)]};
            %
            sparams_tmp.discharge.tmin(jj) = {sparams_tmp.discharge.tmax{jj-1}};
            sparams_tmp.discharge.tmax(jj) = {sparams_tmp.discharge.tmax{jj-1} + dt(1)};
            sparams_tmp.discharge.nt(jj) = {1};
            %
        end
        %
%         % RS I muted it
%         if sparams_tmp.simul.initial_distribution{1} == -1
%             %
%             sparams_tmp.simul.initial_distribution(1) = {-Inf};%write LUKE results (for the first time)
%             %
%         end
        %
        if ii == 1
            %
            sparams_out = sluke_params_merge(sparams_tmp);
            %
        else
            %
            sparams_out = sluke_params_merge(sparams_out,sparams_tmp);
            %
        end
        %
    end
    %
else
    %
    disp('*********************')
    disp(['WARNING : ',status{1}])
    disp('*********************')
    %
end
%
if isfield(sparams_in,'help') && isfield(sparams_in,'format')
    sparams_out.help = sparams_in.help;
    sparams_out.format = sparams_in.format;
end
%
%
