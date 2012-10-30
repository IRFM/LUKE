function [fluct_out] = fluctphase_yp(fluct,mode)
%
% Set the phase in the interpolated fluctuation spectrum
%
% INPUT
%    - fluct: plasma fluctuations structure
%    - mode: pseudo-random number generator (0: Mersenne twister, 1: matlab)
%      (default mode = 1)
%
% OUTPUT: 
%    - fluct_out: plasma fluctuations structure with phase modified or added if necessary
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
if nargin < 1,
	error('Not enough input arguments in fluctphase_yp.m');
end
%
if nargin < 2,
    mode = 1;%rand reset by clock
end
%
fluct_out = fluct;
%
field_name = fieldnames(fluct);
%
for i = 1:length(field_name),
    if isstruct(fluct.(char(field_name(i)))) && (strcmp(char(field_name(i)),'B') || strcmp(char(field_name(i)),'ne') || strcmp(char(field_name(i)),'B_fit') || strcmp(char(field_name(i)),'ne_fit')),
        for ifield = 1:length(fluct.(char(field_name(i)))),
            %
            if fluct.(char(field_name(i)))(ifield).model == 0,%Magnetic ripple (fixed phase)
                phase = [];%no phase needed
            elseif fluct.(char(field_name(i)))(ifield).model >= 1,%random phase approximation (statistical description)
                    dl = fluct.(char(field_name(i)))(ifield).lmax - fluct.(char(field_name(i)))(ifield).lmin + 1;
                    dm = fluct.(char(field_name(i)))(ifield).mmax - fluct.(char(field_name(i)))(ifield).mmin + 1;
                    dn = fluct.(char(field_name(i)))(ifield).nmax - fluct.(char(field_name(i)))(ifield).nmin + 1;
                if mode == 0,
                    [lukeversion,matlabversion] = LUKEversion_jd;
                    if str2num(matlabversion) < 713,
                        RandStream.setDefaultStream(RandStream('mt19937ar','seed',5489));%reset rand with original Mersenne-Twister pseudo-random number generator
                    else
                        RandStream.setGlobalStream(RandStream('mt19937ar','seed',5489));%reset rand with original Mersenne-Twister pseudo-random number generator
                    end
                end
                %
                if fluct.(char(field_name(i)))(ifield).model == 1 || fluct.(char(field_name(i)))(ifield).model == 2,
                	phase = 2*pi*rand(1,dl*dm*dn) - pi;%
                elseif fluct.(char(field_name(i)))(ifield).model == 3 || fluct.(char(field_name(i)))(ifield).model == 6,
                	phase = 2*pi*rand(1,dl*dm) - pi;% 
               	elseif fluct.(char(field_name(i)))(ifield).model == 4 || fluct.(char(field_name(i)))(ifield).model == 5,
                    phase = 2*pi*rand(1,dm) - pi;%
                else
                    error('Error in fluctuation phase calculation, model unrecongized !');
                end
                %
                phase = phase(:)';
            end   
            %   
            fluct_out.(char(field_name(i)))(ifield).phase = phase;
            %
        end
    end
end

























%function [fluct_out] = fluctphase_yp(fluct,dtn,optdisp)
%
% Set the phase in the interpolated fluctuation spectrum
%
% INPUT
%    - fluct: plasma fluctuations structure
%    - dtn: integration time step normalized to the collision time [1,1] 
%      (default = NaN)
%    - optdisp: display option [1,1]
%      (default = 0)
%
% OUTPUT: 
%    - fluct_out: plasma fluctuations structure with phase modified or added if necessary
%
% By Yves Peysson (CEA-DRFC, yves.peysson@cea.fr) and Joan Decker (CEA-DRFC, joan.decker@cea.fr)
%
%if nargin < 1,
%	error('Not enough input arguments in fluctphase_yp.m');
%end
%
%if nargin < 2,
%    dtn = NaN;
%    optdisp = 0;
%end
%
%if nargin < 3,
%    optdisp = 0;
%end
%
%fluct_out = fluct;
%
%field_name = fieldnames(fluct);
%
%for i = 1:length(field_name),
%    if isstruct(fluct.(char(field_name(i)))) && isempty(strfind(char(field_name(i)),'cn')) && isempty(strfind(char(field_name(i)),'cm')) && isempty(strfind(char(field_name(i)),'cn_fit'))  && isempty(strfind(char(field_name(i)),'cm_fit')) && isempty(strfind(char(field_name(i)),'fitparam')),
%        for ifield = 1:length(fluct.(char(field_name(i)))),
%            %
%            nkperp = length(fluct.(char(field_name(i)))(ifield).kp);
%            kpmin = min(fluct.(char(field_name(i)))(ifield).kp);
%            kpmax = max(fluct.(char(field_name(i)))(ifield).kp);
%            if fluct.(char(field_name(i)))(ifield).model == 1,%Gaussian kperp-spectrum (random phase) + electron drift wave
%                if isfield(fluct.(char(field_name(i)))(ifield),'phase') && isfield(fluct.(char(field_name(i)))(ifield),'omegakpn') && ~isnan(dtn),
%                    phase = fluct.(char(field_name(i)))(ifield).phase - fluct.(char(field_name(i)))(ifield).omegakpn*dtn;
%                else
%                    phase = 2*pi*rand(1,nkperp) - pi;
%                end
%            elseif fluct.(char(field_name(i)))(ifield).model == 0,%Magnetic ripple (fixed phase)
%                phase = zeros(1,nkperp); 					
%            else
%                error('Plasma fluctuations model unknown !')
%            end   
%            %   
%            fluct_out.(char(field_name(i)))(ifield).phase = phase;
%            %
%            if isfield(fluct.(char(field_name(i)))(ifield),'phase') && optdisp,
%                figure('Name',['Fluctuation phase ',regexprep(char(field_name(i)), '_fit', '')]),
%                close(['Fluctuation phase ',regexprep(char(field_name(i)), '_fit', '')]);
%                figure('Name',['Fluctuation phase ',regexprep(char(field_name(i)), '_fit', '')]),
%                graph1D_jd(fluct.(char(field_name(i)))(ifield).kp,fluct.(char(field_name(i)))(ifield).phase,0,0,'k*a_p','Phase [-\pi,\pi]',['Fluctuation phase ',regexprep(char(field_name(i)), '_fit', '')],NaN,[kpmin,kpmax],'','none','+','r',2);drawnow
%                graph1D_jd(fluct.(char(field_name(i)))(ifield).kp,fluct_out.(char(field_name(i)))(ifield).phase,0,0,'k*a_p','Phase [-\pi,\pi]',['Fluctuation phase ',regexprep(char(field_name(i)), '_fit', '')],NaN,[kpmin,kpmax],'','none','x','b',2);drawnow
%                legend('Old','New');
%                %
%            end  
%        end
%    end
%end

