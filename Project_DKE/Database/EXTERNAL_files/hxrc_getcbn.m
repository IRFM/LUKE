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
function [ tcbn, cbn, Ebin ] = hxrc_getcbn( shot, ch, t, Echan)
%HXRC_GETCBN [ tcbn, cbn, Ebin ] = hxrc_getcbn( shot, ch, t, Echan)
%   returns the data measured with the HXRC diagnostic, operational in the
%   shot range 15574 to 39214 (camera was not present for all these shots)
%
% INPUT:
%   shot ...... TCV shot number
%   ch ........ channel (5-18 see the plasma, 1-4 and 19 are hidden)
%               (default: 5-18)
%   t ......... time interval, or time point to get closest data point [s]
%               (default: [-Inf,Inf], means all)
%   Echan ..... index of energy channels to be taken
%               (default: 1:8, means all)
%
% OUTPUT:
%   tcbn ...... time base of the measurement [s]
%   cbn ....... chord brightness for the requested chords [counts/s]
%   Ebin ...... energy thresholds (if Echan not all channel, the energy
%               bins may not reach up to the next higher threshold) [keV]
%               Remark: the raw data in the tree contains all counts above
%               the threshold times 0.5, while the output of this function
%               is the countrate in the energy bin from one threshold to
%               the next one, with the last containing the data above the
%               highest threshold.
%
%
% J. Kamleitner, Mar 2014, CRPP, EPFL

if(nargin<2 || isempty(ch))
    ch=5:18;
end
if(nargin<3 || isempty(t))
    t=[-Inf,Inf];
end
if(nargin<4 || isempty(Echan))
    Echan=1:8;
end



nch=length(ch);
nchan=length(Echan);

mdsopen(shot);

% get the energy threshold data
Ebinall=mdsdata('\diagz::hxr_thresholds');
Ebin=Ebinall(Echan).';

% init output for case without data
tcbn=NaN;
cbn=NaN(nch*nchan,1);
flag=true;

for i=1:nch
    for ichan=1:nchan
        % read signal from nodes
        hxrcdata=tdi(sprintf('\\diagz::hxr_counts:chord_%03d:channel_%03d',ch(i),Echan(ichan)));
        if(~mod(hxrcdata.status,2)) % error reading data
            continue;
        end
        if(length(t)>1)
            ihxrctime=(hxrcdata.dim{1}>=t(1) & hxrcdata.dim{1}<=t(2));
        else
            [~,ihxrctime]=min(abs(hxrcdata.dim{1}-t));
        end
        tcbn=hxrcdata.dim{1}(ihxrctime);
        if(flag) % init cbn if has not been init'd
            cbn=NaN(nch*nchan,length(tcbn));
            flag=false;
        end
        % the factor of 2 is documented in the wiki, and the division is
        % necessary to convert from counts to countrate
        if(length(t)>1)
            cbn((ichan-1)*nch+i,:)=2*hxrcdata.data(ihxrctime)/mean(diff(tcbn));
        else
            cbn((ichan-1)*nch+i,:)=2*hxrcdata.data(ihxrctime)/mean(diff(hxrcdata.dim{1}));
        end
    end
end

mdsclose;

% transform data from threshold to energy bin data (as for HXRS)
for i=1:nch
    for ichan=1:(nchan-1)
        cbn((ichan-1)*nch+i,:)=max(cbn((ichan-1)*nch+i,:)-cbn(ichan*nch+i,:),0);
    end
end


end

