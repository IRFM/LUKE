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


 %RCSFGENERATE
 %This program generates a list of CSFs
%
 %Configurations should be entered in spectroscopic notation
 %with occupation numbers and indications if orbitals are
 %closed (c), inactive (i), active (*) or has a minimal
 %occupation e.g. 1s(2,1)2s(2,*)
 %Outputfiles: rcsf.out, rcsfgenerate.log
%
 %Default, reverse, symmetry or user specified ordering? (*/r/s/u)
%*
%
 %Select core 
%        0: No core
%        1: He (       1s(2)                  =  2 electrons)
%        2: Ne ([He] + 2s(2)2p(6)             = 10 electrons)
 %       3: Ar ([Ne] + 3s(2)3p(6)             = 18 electrons)
 %       4: Kr ([Ar] + 3d(10)4s(2)4p(6)       = 36 electrons)
%        5: Xe ([Kr] + 4d(10)5s(2)5p(6)       = 54 electrons)
%        6: Rn ([Xe] + 4f(14)5d(10)6s(2)6p(6) = 86 electrons)
%2
%
% Enter list of (maximum 100) configurations. End list with a blank line or an asterisk (*)
%
% Give configuration           1
%3s(2,*)3p(6,*)
% Give configuration           2
%
% Give set of active orbitals, as defined by the highest principal quantum number
% per l-symmetry, in a comma delimited list in s,p,d etc order, e.g. 5s,4p,3d
%3s,3p
% Resulting 2*J-number? lower, higher (J=1 -> 2*J=2 etc.)
%0
%0
% Number of excitations (if negative number e.g. -2, correlation 
% orbitals will always be doubly occupied)                        
%0
% Generate more lists ? (y/n)
%n
%  Excitationdata file opened
%
 %THE LINES BELOW ARE DEBUG OUTPUT FROM THE
% CSF GENERATOR:   PLEASE IGNORE !!!       
%
%     *  : new list
%     e  : expand existing list
%     q  : quit
% Default, reverse, symmetry or user specified ordering? (*/r/s/u)
% Highest principal quantum number, n? (1..15)
% Highest orbital angular momentum, l? (s..d)
% Are all these nl-subshells active? (n/*)
% Limitations on population of n-subshells? (y/*)
% Highest n-number in reference configuration? (1..3)
% Predefine open, closed or no core? (o/c/*)
% Select core,
%      1: He (       1s(2)                  =  2 electrons)
%      2: Ne ([He] + 2s(2)2p(6)             = 10 electrons)
%      3: Ar ([Ne] + 3s(2)3p(6)             = 18 electrons)
% 1s is part of the predefined core.
% 2s is part of the predefined core.
% 2p is part of the predefined core.
% Number of electrons in 3s? (0..2)
% Closed, inactive, active or minimum? (c/i/*/0..1)
% Number of electrons in 3p? (0..6)
% Closed, inactive, active or minimum? (c/i/*/0..5)
% Resulting 2*J-number? lower, higher (J=1 -> 2*J=2 etc.)
% Number of excitations = ? (0..8)
% One configuration state has been generated.
% One configuration state in the final list.
% Generate another list? (y/*)
%
% Group CSFs into symmetry blocks
%
% 1 blocks were created
%
%       block  J/P            NCSF
%           1    0+              1

%core and configurations
%
rcsfgenerate.order = '*';
rcsfgenerate.core = 2;
rcsfgenerate.config{1} = '3s(2,*)3p(6,*)';
rcsfgenerate.config{2} = '*';
rcsfgenerate.config{3} = '3s,3p';
rcsfgenerate.Jmin = 0;
rcsfgenerate.Jmax = 0;               
rcsfgenerate.excitation = 0;
%{
rcsfgenerate << eof
* ! Orbital order
2  ! Selected core
3s(2,*)3p(6,*)
*
3s,3p
           0           0  ! Lower and higher 2*J
           0  ! Number of excitations
n
%}