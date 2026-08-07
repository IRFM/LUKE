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
function sparams_out = sluke_params_clone(varargin)
%
% LUKE - Clone fields of simulation parameters structure for sluke calculations. All parameters are in a structure of cell arrays of the SAME SIZE. 
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
sparams_out = {};
%
if nargin == 3
    %
    sparams_in = varargin{1};
    jclone = varargin{2};%indexes of the structure to be cloned
    kclone = varargin{3};%number of clone series
    %
elseif nargin == 2
    %
    sparams_in = varargin{1};
    jclone = varargin{2};%index of the structure to be cloned
    %
elseif nargin == 1
    %
    sparams_in = varargin{1};
    %
else
    %
    error('Wrong number of input arguments in sluke_params_clone function');
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
    if nargin < 2
        %
        jclone = input_dke_yp(['Which indexes to be cloned (index max = ',int2str(nf0),')'],1,[1:nf0]);
        %
    end
    %
    if nargin < 3
        %
        kclone = input_dke_yp(['Number of clone series'],1);
        %
    end
    %
    if isfield(sparams_in,'help') && isfield(sparams_in,'format')
        %
        sparams_out = rmfield(sparams_in,{'help','format'});
        %
    else
        %
        sparams_out = sparams_in;
        %
    end
    %
    mm = 1;
    %
    for kk = 1:kclone
        %
        for jj = 1:length(jclone)
            %
            %disp([mm,kk,jj,jclone(jj)])
            %disp(['sparams_out.',fns{1},'{',int2str(nf0+mm),'} = sparams_in.',fns{1},'{',int2str(jclone(jj)),'};'])
            %
            for ii = 1:length(fns)
                %
               % eval(['sparams_out.',fns{ii},'{',int2str(nf0+jj+kk-1),'} = sparams_in.',fns{ii},'{',int2str(jclone(jj)),'};']);
                eval(['sparams_out.',fns{ii},'{',int2str(nf0+mm),'} = sparams_in.',fns{ii},'{',int2str(jclone(jj)),'};']);
                %
            end
            %
            mm = mm + 1;
            %
        end
        %
 
    end
    %
end
%
if isfield(sparams_in,'help') && isfield(sparams_in,'format')
    sparams_out.help = sparams_in.help;
    sparams_out.format = sparams_in.format;
end
%


