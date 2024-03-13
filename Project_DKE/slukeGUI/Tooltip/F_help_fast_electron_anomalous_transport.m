function varargout = F_help_fast_electron_anomalous_transport(key)
%   F_help_fast_electron_anomalous_transport()
%   help = F_help_fast_electron_anomalous_transport(key)
%
%plot help for fast_electron_anomalous_transport substruct or find help 
%for specific field of fast_electron_anomalous_transport defined in key

tp.comment  = "Comments on the model (context, author for example)";
tp.source   = "Source of the fast electron anomalous transport parameters: 'preset', 'code' or 'file'";
tp.code     = "Code name, needed if source is 'code'";
tp.file     = "File name, needed if source is 'file";
tp.path     = "File path, needed if source is 'file'";
tp.preset   = "Preset name, needed if source is 'preset'";
tp.Dr_type  = "Anomalous fast electron radial diffusion type : ES -> electrostatic (no v|| dependence), EM -> electromagnetic (EM or EM+: v|| dependence, EM-: 1/v|| dependence)";
tp.Dr0      = "Radial diffusion (m^2/s). Dr0 = Dr_center + i*Dr_edge";
tp.pDr      = "Profile dependence (pDr = pDr0 + i*pDr1) : if pDr is real (flat or parabolic increase from center to the edge): Dr(rho) = Dr_center*(1+pDr0*rho^2). If pDr is imaginary (step size from center to the edge): Dr(rho) = (Dr_center-Dr_edge)/(1+exp((rho-pDr0)/pDr1))+Dr_edge";
tp.Vr_type  = "Anomalous fast electron radial pinch type : ES -> electrostatic (no v|| dependence), EM -> electromagnetic (EM or EM+: v|| dependence, EM-: 1/v|| dependence)'";
tp.Vr0      = "Radial pinch (m/s). Vr0 = Vr_center + i*Vr_edge";
tp.pVr      = "Profile dependence (pVr = pVr0 + i*pVr1) : if pVr is real (flat or parabolic increase from center to the edge): Vr(rho) = Vr_center*(1+pVr0*rho^2). If pVr is imaginary (step size from center to the edge): Vr(rho) = (Vr_center-Vr_edge)/(1+exp((rho-pVr0)/pVr1))+Vr_edge";
tp.vparmin  = "Velocity threshold in normalized units";
tp.norm_ref = "Normalization of the velocity threshold: (0) v||/vT (local), (1) v||/vT_ref (central value)";
        
if ~exist('key','var'),     key = {};   end

help  = get_tooltip(tp,key);
if nargout >= 1
    varargout{1} = help;
end

end