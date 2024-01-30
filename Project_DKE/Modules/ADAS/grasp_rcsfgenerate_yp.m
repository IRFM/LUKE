function [rcsfgenerate] = grasp_rcsfgenerate_yp(Z,Z0,code)
%
%   Calculation script of the atomic electron density for all ionization states of an
%   atom with atomic number Z. To be used with MCDHF GRASP2018 code to calculate the
%   atomic electron density like GRASP2018, .... Matlab is
%   supposed to be installed on the computer on which the MCDHF calculations are done. 
%
%   For examples of GRASP2018 calculations wisit the webpages 
%       - https://www.diracprogram.org/doc/release-12/exercises/computer_grasp.html
%       - https://www.diracprogram.org/doc/release-17/exercises/computer_grasp.html
%
%   INPUTS:
%
%       - Z : atomic number vector [1,1]
%       - Z0 : ionization states (Z0 < Z) [1,1]
%       - code : grasp code parameters structure [1,1]
%
%   OUTPUTS:
%
%       - rcsfgenerate : rcsfgenerate structure for grasp2018 code script
%
%   By Y. Savoye-Peysson CEA-IRFM <yves.savoye-peysson@cea.fr>
%
if nargin < 3
    %
    error('Error: not enough input arguments in grasp_rcsfgenerate_yp.m.');
    %
end
%
ground_state = atomic_groundstates(Z);% from NIST database
%
rcsfgenerate.order = code.rcsfgenerate.order;%default, reverse, symmetry or user specified ordering? (*/r/s/u)
rcsfgenerate.core = ground_state(Z0+1).core.grasp;%code 
rcsfgenerate.config{1} = ground_state(Z0+1).configuration;%orbitals closed (c), inactive (i), active (*) or has a minimal occupation e.g. 1s(2,1)2s(2,*)
rcsfgenerate.config{2} = '*';%end number of orbitals. Here just one is considered
rcsfgenerate.config{3} = ground_state(Z0+1).active_orbitals;%set of active orbitals, as defined by the highest principal quantum number per l-symmetry, in a comma delimited list in s,p,d etc order, e.g. 5s,4p,3d
rcsfgenerate.Jmin = ground_state(Z0+1).Jmin;% 2*J-number? lower (J=1 -> 2*J=2 etc.)
rcsfgenerate.Jmax = ground_state(Z0+1).Jmax;% 2*J-number? higher (J=1 -> 2*J=2 etc.)
rcsfgenerate.excitation = code.rcsfgenerate.excitation;%number of excitations (if negative number e.g. -2, correlation  orbitals will always be doubly occupied)        
                