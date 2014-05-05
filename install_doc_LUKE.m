function install_doc_LUKE(verbose)
%LUKE - Installation script for automatic generation of the on-line documentation 
%
%Installation script for automatic generation of the on-line documentation using MatHelp library
%
% INPUT:
%
%	- verbose: display the output of the documentation build-up is not empty
%
% OUTPUT: none
%
%By Yves Peysson (CEA/DSM/IRFM, yves.peysson@cea.fr) and Joan Decker (CEA/DSM/IRFM, joan.decker@cea.fr) 
%
if nargin == 0,
    verbose = 1;
end
%
excludedfoldernames = {'EAST','HL2A','AMR'};%update if necessary
%
disp('************************* EXCLUDED FOLDER NAMES **************************')
for ie = 1:length(excludedfoldernames),
    disp([' - ',excludedfoldernames{ie}])
end
disp('**************************************************************************')
%
dirinit = pwd;
%
dkepath = load_structures_yp('dkepath','','');
luke_root = dkepath.luke_root;
%
helptools = '';
%
if isfield(dkepath,'latex') && isfield(dkepath.latex,'env') && ~isempty(dkepath.latex.env),
    helptools.htlatex = dkepath.latex.env;
    helptools.pdflatex = dkepath.latex.env;
end
%
if isfield(dkepath,'imagemagick') && isfield(dkepath.imagemagick,'env') && ~isempty(dkepath.imagemagick.env),
    helptools.imagemagick = dkepath.imagemagick.env;
end
%
if isfield(dkepath,'graphviz') && isfield(dkepath.graphviz,'env') && ~isempty(dkepath.graphviz.env),
    helptools.graphviz = dkepath.graphviz.env;
end
%
texfilelist(1).file = 'Project_DKE/Doc/NoticeDKE';texfilelist(1).title = '3-D linearized relativistic bounce-averaged electron drift kinetic solver (LUKE)';
texfilelist(2).file = 'Project_DKE/Modules/C3PO/Doc/raytracing';texfilelist(2).title = 'Universal multi-wave ray-tracing (C3PO)';
texfilelist(3).file = 'Project_DKE/Modules/FEB/Doc/3Tmodel';texfilelist(3).title = 'Fast electron bremsstrahlung (R5-X2)';
%
make_help(luke_root,texfilelist,excludedfoldernames,helptools,verbose)
%
cd(dirinit);
