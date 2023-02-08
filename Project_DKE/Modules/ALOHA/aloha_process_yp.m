function sc_out = aloha_process_yp(sc_in,rc,optim)
%
if ~isfield(optim,'nitmax')
    nitmax = 7;
else
    if optim.nitmax < 7
        nitmax = 7;
    else
        nitmax = optim.nitmax;
    end
end
%
ne0 = linspace(optim.ne_guess(1),optim.ne_guess(2),nitmax);% coarse grid
%
% calculate ALOHA for all densities on the coarse grid
%
%sc_in.antenna.a_ampl(imag(sc_in.antenna.a_ampl) == 1) = 1;%Enforced very small and positive value to avoid error is power in module is negative (power is 1 W)
%
for ii = 1:nitmax
    %
    sc(ii) = sc_in;
    %
    sc(ii).plasma.ne0 = ne0(ii);
    %
    sc(ii) = aloha_scenario(sc(ii));
    %
    mask_klystrons = sc(ii).results.Pin > 5000;%less than 5kW of LH power per module corresponds to a technical failure
    %
    err_RC(ii) = norm(sc(ii).results.RC(mask_klystrons) - rc(mask_klystrons));%for working klystrons only
    %
end
%
% Fit the error with experimental measurements
%
ii_min = find(err_RC == min(err_RC));
%
ne_optim = 2e17;%defaut value since problem in RC in order to avoid code break
%
enforce_mode = 1;
%
if ~isempty(ii_min) && ii_min >= 3 && ii_min <= length(ne0)-2 && ~all(isnan(err_RC))
    %
    nfit = 2;
    %
    ne0_ref_mean = mean(ne0(ii_min-nfit:ii_min+nfit));
    ne0_ref = ne0(ii_min-nfit:ii_min+nfit)/ne0_ref_mean;
    err_RC_ref = err_RC(ii_min-nfit:ii_min+nfit);
    %
    p = polyfit(ne0_ref,err_RC_ref,length(err_RC_ref)-1);
    ne1 = linspace(ne0(ii_min-nfit),ne0(ii_min+nfit),1000);% fine grid
    err_RC_fit = polyval(p,ne1/ne0_ref_mean);
    ne_optim = ne1(find(err_RC_fit == min(err_RC_fit)));
    %
    %plot(ne0,err_RC,'ro-',ne0_ref,err_RC_ref,'b*--',ne1,err_RC_fit,'gx-.')
    %
    enforce_mode = 0;
    %
end
%
if ne_optim < optim.ne_guess(1) || ne_optim > optim.ne_guess(2) || isnan(ne_optim) || isempty(ne_optim) || isinf(ne_optim)
    %
    ne_optim = 1e17;%defaut value since problem in RC in order to avoid code break
    %
    enforce_mode = 1;
    %
end
%
sc_out = sc_in;
%
sc_out.plasma.ne0 = ne_optim;
%
sc_out = aloha_scenario(sc_out);
%
if isfield(optim,'debugmode') && optim.debugmode == 1
    %
    sc_out.simul.sc = sc;%uncomment for debug only
    sc_out.simul.sc_out = sc_out;%uncomment for debug only
    sc_out.simul.sc_in = sc_in;%uncomment for debug only
    %
end
%
sc_out.simul.nitmax = nitmax;
sc_out.simul.ne0 = ne0;
%
if exist('nfit')
    %
    sc_out.simul.nfit = nfit;
    %
end
%
if exist('ne1')
    %
    sc_out.simul.ne1 = ne1;
    %
end
%
if exist('err_RC')
    %
    sc_out.simul.err_RC = err_RC;
    %
end
%
if exist('err_RC_fit')
    %
    sc_out.simul.err_RC_fit = err_RC_fit;
    %
end
%
if exist('p')
    %
    sc_out.simul.p = p;
    %
end
%
if exist('rc')
    %
    sc_out.simul.rc = rc;
    %
end
%
if exist('optim')
    %
    sc_out.simul.optim = optim;
    %
end
%
sc_out.simul.ne_optim = ne_optim;
sc_out.simul.enforce_mode = enforce_mode;
%

    
    
    
