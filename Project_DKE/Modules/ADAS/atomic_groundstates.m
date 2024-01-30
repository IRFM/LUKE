function [ground_state] = atomic_groundstates(Z)
%
% Ground states from NIST database for elements important for plasma physics : 
% H, He, Li, Be, B, C, N, O, Ne, Al, Si, Cl, Ar, Cr, Fe, Ni, Cu, Ge, Kr, Mo, Xe, W, Pt, Au
%
% Argon --> https://physics.nist.gov/cgi-bin/ASD/ie.pl?spectra=Ar&units=1&shells_out=on&level_out=on
% Tungsten --> https://physics.nist.gov/cgi-bin/ASD/ie.pl?spectra=W&units=1&shells_out=on&level_out=on
%
%   INPUTS:
%
%       - Z : atomic number [1,1]
%
%   OUTPUTS:
%
%       - ground_state : ground-state structure
%
%   NOTE :
%
%        0: No core
%        1: He (       1s(2)                  =  2 electrons)
%        2: Ne ([He] + 2s(2)2p(6)             = 10 electrons)
%        3: Ar ([Ne] + 3s(2)3p(6)             = 18 electrons)
%        4: Kr ([Ar] + 3d(10)4s(2)4p(6)       = 36 electrons)
%        5: Xe ([Kr] + 4d(10)5s(2)5p(6)       = 54 electrons)
%        6: Rn ([Xe] + 4f(14)5d(10)6s(2)6p(6) = 86 electrons)
%
%   By Y. Savoye-Peysson CEA-IRFM <yves.savoye-peysson@cea.fr>
%
if nargin < 1
    %
    error('Error: not enough input arguments in atomic_groundstates.m.');
    %
end
%
ii = 0;
%
if Z == 1 % Hydrogen
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
elseif Z == 2 %Helium
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
elseif Z == 3 %Lithium
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    %
elseif Z == 4 %Beryllium
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
elseif Z == 5 %Boron
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    %
elseif Z == 6 %Carbon
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
elseif Z == 7 %Nitrogen
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(3,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    %
elseif Z == 8 %Oxygen 
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(4,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(3,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
elseif Z == 10 %Neon
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(6,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(5,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(4,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(3,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
elseif Z == 13 %Aluminium
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(6,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(5,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(4,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(3,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular mom_grasp2018_29-01-2024_15:04:50entum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
elseif Z == 14 %Silicium
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(6,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(5,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(4,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(3,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
elseif Z == 17 %Chlorine
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(5,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(4,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(3,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(6,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(5,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(4,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(3,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
elseif Z == 18 % Argon
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(6,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(5,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(4,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(3,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(6,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(5,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(4,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(3,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
elseif Z == 24 % Chromium
    %

    %
elseif Z == 26 % Iron
    %
    %
elseif Z == 28 % Nickel
    %

    %
elseif Z == 29 % Copper
    %

    %
elseif Z == 32 % Germanium
    %

    %
elseif Z == 36 % Krypton
    %

    %
elseif Z == 42 % Molybden
    %

    %
elseif Z == 54 % Xenon
    %

    %
elseif Z == 74 % Tungsten
    %
    ii = ii + 1;%w0
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 5;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Xe';%core
    ground_state(ii).configuration = '4f(14,*)5d(4,*)6s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '6s,5d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;%w1
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 5;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Xe';%core
    ground_state(ii).configuration = '4f(13,*)5d(4,*)6s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '6s,5d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;%w2
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 5;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Xe';%core
    ground_state(ii).configuration = '4f(12,*)5d(4,*)6s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '6s,5d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;%w3
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 5;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Xe';%core
    ground_state(ii).configuration = '4f(11,*)5d(4,*)6s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '6s,5d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;%w4
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 5;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Xe';%core
    ground_state(ii).configuration = '4f(10,*)5d(4,*)6s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '6s,5d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;%w5
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 5;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Xe';%core
    ground_state(ii).configuration = '4f(9,*)5d(4,*)6s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '6s,5d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;%w6
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 5;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Xe';%core
    ground_state(ii).configuration = '4f(8,*)5d(4,*)6s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '6s,5d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;%w7
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 5;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Xe';%core
    ground_state(ii).configuration = '4f(7,*)5d(4,*)6s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '6s,5d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;%w8
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 5;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Xe';%core
    ground_state(ii).configuration = '4f(6,*)5d(4,*)6s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '6s,5d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(2);%2*(total angular momentum quantum number)
    %

    ii = ii + 1;%w9
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 5;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Xe';%core
    ground_state(ii).configuration = '4f(5,*)5d(4,*)6s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '6s,5d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %

    ii = ii + 1;%w10
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4f(4,*)5d(4,*)6s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '6s,5d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %

    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(10,*)5s(2,*)4f(13,*)5p(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '5s,5p,4d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(7/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(7/2);%2*(total angular momentum quantum number)
    %


    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(10,*)5s(2,*)4f(14,*)';%active orbitals
    ground_state(ii).active_orbitals = '5s,4d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %

    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(10,*)5s(2,*)4f(13,*)';%active orbitals
    ground_state(ii).active_orbitals = '5s,4d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(7/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(7/2);%2*(total angular momentum quantum number)
    %


    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(10,*)5s(2,*)4f(12,*)';%active orbitals
    ground_state(ii).active_orbitals = '5s,4d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(6);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(6);%2*(total angular momentum quantum number)
    %


    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(10,*)5s(2,*)4f(11,*)';%active orbitals
    ground_state(ii).active_orbitals = '5s,4d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(15/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(15/2);%2*(total angular momentum quantum number)
    %

%Kr core
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(10,*)4f(11,*)5s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '5s,4d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(8);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(8);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(10,*)4f(11,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(15/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(15/2);%2*(total angular momentum quantum number)
    %
     ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(10,*)4f(10,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(8);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(8);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(10,*)4f(9,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(15/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(15/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(10,*)4f(8,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(6);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(6);%2*(total angular momentum quantum number)
    %
   ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(10,*)4f(7,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(7/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(7/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(10,*)4f(6,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(10,*)4f(5,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(5/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(5/2);%2*(total angular momentum quantum number)
    %




    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(10,*)4f(4,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(4);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(4);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(10,*)4f(3,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(9/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(9/2);%2*(total angular momentum quantum number)
    %

    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(10,*)4f(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(4);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(4);%2*(total angular momentum quantum number)
    %

    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(10,*)4f(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d,4f';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(5/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(5/2);%2*(total angular momentum quantum number)
    %

    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(10,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(9,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(5/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(5/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(8,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(4);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(4);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(7,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(9/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(9/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(6,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(4);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(4);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(5,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(5/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(5/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(4,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(3,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(2);%2*(total angular momentum quantum number)
    %

    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 4;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Kr';%core
    ground_state(ii).configuration = '4d(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '4d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %

%Ar core

    % 
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 3;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ar';%core
    ground_state(ii).configuration = '3d(10,*)4s(2,*)4p(6,*)';%active orbitals
    ground_state(ii).active_orbitals = '4s,4p,3d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 3;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ar';%core
    ground_state(ii).configuration = '3d(10,*)4s(2,*)4p(5,*)';%active orbitals
    ground_state(ii).active_orbitals = '4s,4p,3d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 3;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ar';%core
    ground_state(ii).configuration = '3d(10,*)4s(2,*)4p(4,*)';%active orbitals
    ground_state(ii).active_orbitals = '4s,4p,3d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 3;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ar';%core
    ground_state(ii).configuration = '3d(10,*)4s(2,*)4p(3,*)';%active orbitals
    ground_state(ii).active_orbitals = '4s,4p,3d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 3;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ar';%core
    ground_state(ii).configuration = '3d(10,*)4s(2,*)4p(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '4s,4p,3d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 3;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ar';%core
    ground_state(ii).configuration = '3d(10,*)4s(2,*)4p(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '4s,4p,3d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 3;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ar';%core
    ground_state(ii).configuration = '3d(10,*)4s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '4s,3d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 3;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ar';%core
    ground_state(ii).configuration = '3d(10,*)4s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '4s,3d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 3;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ar';%core
    ground_state(ii).configuration = '3d(10,*)';%active orbitals
    ground_state(ii).active_orbitals = '3d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 3;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ar';%core
    ground_state(ii).configuration = '3d(9,*)';%active orbitals
    ground_state(ii).active_orbitals = '3d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(5/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(5/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 3;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ar';%core
    ground_state(ii).configuration = '3d(8,*)';%active orbitals
    ground_state(ii).active_orbitals = '3d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(4);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(4);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 3;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ar';%core
    ground_state(ii).configuration = '3d(7,*)';%active orbitals
    ground_state(ii).active_orbitals = '3d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(9/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(9/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 3;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ar';%core
    ground_state(ii).configuration = '3d(6,*)';%active orbitals
    ground_state(ii).active_orbitals = '3d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(4);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(4);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 3;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ar';%core
    ground_state(ii).configuration = '3d(5,*)';%active orbitals
    ground_state(ii).active_orbitals = '3d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(5/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(5/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 3;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ar';%core
    ground_state(ii).configuration = '3d(4,*)';%active orbitals
    ground_state(ii).active_orbitals = '3d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 3;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ar';%core
    ground_state(ii).configuration = '3d(3,*)';%active orbitals
    ground_state(ii).active_orbitals = '3d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 3;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ar';%core
    ground_state(ii).configuration = '3d(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '3d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 3;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ar';%core
    ground_state(ii).configuration = '3d(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '3d';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(6,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(5,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(4,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(3,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)3p(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s,3p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 2;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'Ne';%core
    ground_state(ii).configuration = '3s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '3s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(6,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(5,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(4,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(3,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(3/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(3/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)2p(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s,2p';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 1;%predefineed core (grasp definition)
    ground_state(ii).core.name = 'He';%core
    ground_state(ii).configuration = '2s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '2s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(2,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(0);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(0);%2*(total angular momentum quantum number)
    %
    ii = ii + 1;
    ground_state(ii).Z0 = ii-1;%ionization state
    ground_state(ii).core.grasp = 0;%predefineed core (grasp definition)
    ground_state(ii).core.name = '';%core
    ground_state(ii).configuration = '1s(1,*)';%active orbitals
    ground_state(ii).active_orbitals = '1s';%active orbitals ordered by principal quantum number
    ground_state(ii).Jmin = 2*(1/2);%2*(total angular momentum quantum number)
    ground_state(ii).Jmax = 2*(1/2);%2*(total angular momentum quantum number)
    %
elseif Z == 78 % Platinum
    %

    %
elseif Z == 79 % Gold
    %

    %
elseif Z == 18 % Argon
    %

    %
else
    %
    name = elements('atomic_number',Z,'name');
    symbol = elements('atomic_number',Z,'symbol');
    %
    error(['The element ',name,' (',symbol,', Z = ,',int2str(Z),') is not yet implemented. See the NIST database. '])
    %
end


