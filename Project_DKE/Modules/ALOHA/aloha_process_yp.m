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
ne1 = linspace(optim.ne_guess(1),optim.ne_guess(2),1000);% fine grid
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
    err_RC(ii) = norm(sc(ii).results.RC - rc);
    %
end
%
% Fit the error with experimental measurements
%
p = polyfit(ne0,err_RC,nitmax);
err_RC_fit = polyval(p,ne1);
ne_optim = ne1(find(err_RC_fit == min(err_RC_fit)));
%
sc_out = sc_in;
%
sc_out.plasma.ne0 = ne_optim;
%
sc_out = aloha_scenario(sc_out);
%
sc_out.simul.sc = sc;
sc_out.simul.sc_out = sc_out;
sc_out.simul.sc_in = sc_in;
sc_out.simul.nitmax = nitmax;
sc_out.simul.ne0 = ne0;
sc_out.simul.ne1 = ne1;
sc_out.simul.err_RC = err_RC;
sc_out.simul.rc = rc;
sc_out.simul.optim = optim;
sc_out.simul.p = p;
sc_out.simul.err_RC_fit = err_RC_fit;
sc_out.simul.ne_optim = ne_optim;
%

    
    
    
