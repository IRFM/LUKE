function varargout = F_help_dkeparam(key)
%   F_help_dkeparam()
%   help = F_help_dkeparam(key)
%
%plot help for dkeparam substruct or find help for specific field of dkeparam
%defined in key

tp.comment  = "Comments on the kinetics dkeparam parameters";
tp.source   = "'preset', 'code' or 'file', source of dkeparam";
tp.preset   = "Preset name, needed if source is 'preset'";
tp.file     = "File name, needed if source is 'file'";
tp.path     = "Path where to find the file to create dkeparam, needed if source == 'file' or 'code'";
tp.clustermode = {"", @F_help_clustermode};
tp.nmhu_S   = "Enforced value : number of angular values for the flux grid (WARNING: odd number) (>100 recommended for accurate run)";
tp.np_S     = "Enforced value : number of momentum values for the flux grid (pnmax/np < 0.1 highly recommended for accurate run) WARNING: must be adjusted so that effective momentum point number is larger than thepitch-angle one.";
tp.pnmax_S  = "Enforced value : maximum value of the flux momentum grid (pth_ref)";
tp.pmax     = "Enforced value : maximum value of the flux momentum grid times pth_ref (keV)"; %RS?
tp.snp      = "Enforced value : refinement factor for momentum grid towards pn = 0 (10 --> ten times denser)"; %RS?
tp.grid_power =  ""; %RS?
tp.coll_time= "Enforced value: time over wich integrate DKE equation normalised to the collision time";
tp.coll_dt  = "Enforced value: single integration time step. If Nan enforced to be equal to coll_time";
tp.coll_mode= "Collision operator model. (0) -> Relativistic Maxwellian background, (1) -> High-velocity limit, (2) -> Linearized Belaiev-Budker (3) -> Non-relativistic Lorentz model, (4) -> Non-relativistic Maxwellian background. For simulation: recommended 2.";
tp.rho_S	= "(1) -> single real value larger than 1 : number of points for radial grid calculation (automatic and optimized for depending the type of RF waves), (2) -> single or multiple real values less than 1 : manual radial flux grid, (3) -> imaginary values : npoints + 1i*normalized_radial_position ([5+0.1*i,12+0.7*i,3+1.0i]";
tp.psin_S   = "Enforced value: radial normalised flux grid";
tp.dpsin_dke= "";
tp.dke_mode = "";
tp.sfac0    ="Enforced value: reduction factor for fine grid near mhu = 0";
tp.sfac1    = "Enforced value: reduction factor for fine grid near mhu = 1";
tp.sfact    = "Enforced value: reduction factor for fine grid near mhu = mhut";
tp.snmhu0   = "Enforced value: number of fine grid points near mhu = 0";
tp.snmhu1   = "Enforced value: number of fine grid points near mhu = 1";
tp.snmhut   = "Enforced value: number of fine grid points near mhu = mhut";
tp.Te_ref   = "It is possible to impose rerefence value for temperature. If not evaluated automatically.";
tp.ne_ref   = "It is possible to impose rerefence value for density. If not evaluated automatically.";
                                        
if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end