function jt = jt_rho_theta_input(rho,theta,equil)
% only used if jt was given as an input

if isfield(equil.current,'jt')
    if isfield(equil.current.jt,'profile')
        jt = interp2(equil.current.jt.thetas,equil.current.jt.rhos,equil.current.jt.profile,theta,rho);
    end
else
    error('No input profile has been entered for jt');
end

end