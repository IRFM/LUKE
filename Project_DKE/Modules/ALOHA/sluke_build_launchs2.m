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
function [launchs] = sluke_build_launchs(sparams)
%









%
for ii = 1:length(iantennas)
    %
    ia = iantennas(ii);
    %
    [launch.bNtor0,launch.bdNtor0,launch.bPlhtor,param_tor] = proc_aloha_spec_jd(antennas(ia).aloha.results.nz,NaN,real(antennas(ia).aloha.results.dP_nz),params.aloha2c3po.Plhtot,params.aloha2c3po,params.aloha2c3po.opt_optim,params.aloha2c3po.sdisplay);
    % 
    launch.id = [cellfun(@(c) c(1),strsplit(data_lh(ia).machine)),'_',int2str(data_lh(ia).shot),'_',data_lh(ia).port,'_',strrep(num2str(data_lh(ia).mean.tmin),'.','p'),'_',strrep(num2str(data_lh(ia).mean.tmmax),'.','p')];
    %
    launch.type = data_lh(ia).type;
    %
    launch.omega_rf = data_lh(ia).antenna_frequency*2*pi;%rad/s
    launch.rZ0 = data_lh(ia).row_z_positions;
    %
    launch.phi0 = params.launch.phi0
    launch.LFS = params.launch.LFS
    %
    launch.m0 = params.launch.m0
    launch.i_ref = params.launch.i_ref
    launch.mmode = params.launch.mmode
    %
    launch.spectrum.dP = ;          
    launch.spectrum.dP_nz = ;
    launch.spectrum.nz = ;
    launch.spectrum.ny = ;
    launch.spectrum.Plhtot = ;
    launch.spectrum.param_tor = param_tor;
    launch.spectrum.param_pol = params.launch.param_pol;
    %
    if isfield(params.launch,'tail')
        launch.tail = params.launch.tail;
    end
    %
    launch.n0 = params.launch.n0;
    launch.kz0 = params.launch.kz0;
    launch.ns = params.launch.n;
    %
    launch.method1 = params.launch.method1;
    launch.method2 = params.launch.method2;
    %
    antennas(ia).launch = launch;
    %
    clear launch
    %
end
