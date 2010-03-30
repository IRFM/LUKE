function transpfaste = imake_transp_jd(dkepath,basestr,equil,external,workdir,opt_gui)
%
% This function interactively builds the ohm structure
%
transpfaste = '';
%
Dr_model = input('Radial diffusion type: \n0 electrostatic (no v|| dependence), \n1 electromagnetic (linear increase with v||) \n[0] : ');
if isempty(Dr_model),
    Dr_model = 0;
end
if ~isnumeric(Dr_model) | ~any(Dr_model == [0,1]),
    disp('-----> Invalid Radial diffusion type');
    return
end
%
Vr_model = input('Radial pinch type: \n0 electrostatic (no v|| dependence), \n1 electromagnetic (linear increase with v||) \n[0] : ');
if isempty(Vr_model),
    Vr_model = 0;
end
if ~isnumeric(Vr_model) | ~any(Vr_model == [0,1]),
    disp('-----> Invalid Radial pinch type');
    return
end
%
vparmin = input('threshold in v|| / vT [3.5] : ');
if isempty(vparmin),
    vparmin = 3.5;
end
if ~isnumeric(vparmin),
    disp('-----> Invalid Radial pinch type');
    return
end
%
norm_ref = input('Normalization of threshold: (0) v|| / vT, (1) v|| / vT_ref [1] : ');
if isempty(norm_ref),
    norm_ref = 1;
end
if ~isnumeric(norm_ref) | ~any(norm_ref == [0,1]),
    disp('-----> Invalid option');
    return
end
%
Dr0 = input('Core radial diffusion coefficient (m^2/s) [1.0]');
if isempty(Dr0),
    Dr0 = 1.0;
end
if ~isnumeric(Dr0),
    disp('-----> Invalid Dr0');
    return
end
%
pDr = input('Coefficient for the radial profile of the diffusion coefficient [0]');
if isempty(pDr),
    pDr = 0;
end
if ~isnumeric(pDr),
    disp('-----> Invalid pDr');
    return
end
%
Vr0 = input('Core radial pinch coefficient (m/s) [0.0]');
if isempty(Vr0),
    Vr0 = 0.0;
end
if ~isnumeric(Vr0),
    disp('-----> Invalid Dr0');
    return
end
%
pVr = input('Coefficient for the radial profile of the pinch coefficient [0]');
if isempty(pVr),
    pVr = 0;
end
if ~isnumeric(pVr),
    disp('-----> Invalid pDr');
    return
end
%
transpfaste.Dr0 = Dr0;
transpfaste.pDr = pDr;
transpfaste.Vr0 = Vr0;
transpfaste.pVr = pVr;
%
transpfaste.Dr_model = Dr_model;
transpfaste.Vr_model = Vr_model; 
transpfaste.vparmin = vparmin;%Normalized units
transpfaste.norm_ref = norm_ref;
%    
if Dr_model == 1,
    id_transpfaste_i = 'EM';
else
    id_transpfaste_i = 'ES';
end
%
id_transpfaste = input(['Please specify a name for the transpfaste structure : [',id_transpfaste_i,'] : '],'s');
if isempty(id_transpfaste),
    id_transpfaste = id_transpfaste_i;
end
transpfaste.id = id_transpfaste;
%





