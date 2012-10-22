function luke_output = runluke(luke_input)
%
dkepath = load_structures_yp('dkepath','','');
%
warning off
%
[luke_output.Znorm,luke_output.Zcurr,luke_output.ZP0,luke_output.dke_out,luke_output.radialDKE,...
        luke_output.equilDKE,luke_output.momentumDKE,luke_output.gridDKE,luke_output.Zmomcoef,luke_output.Zbouncecoef,luke_output.Zmripple,luke_output.mksa,luke_output.XXsinksource] = ...
    run_lukert(luke_input.simul_in,luke_input.wavestructs,luke_input.waves,luke_input.dkeparam.psin_S,luke_input.dkeparam.rho_S,dkepath,...
        luke_input.equil,luke_input.dkeparam,luke_input.dkedisplay,luke_input.ohm,luke_input.transpfaste,luke_input.ripple,luke_input.Zf0_interp,luke_input.XXsinksource,luke_input.opt_save);   
%
