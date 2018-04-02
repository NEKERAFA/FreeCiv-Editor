% Rafael Alcalde Azpiazu - 17 Mar 2018
% Facultade de Informática da Coruña - Universidade da Coruña
%
% This file defines the values to create a map
%

%%%% CONSTANTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#const rows = 8.
#const cols = 8.

%%%% TYPES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Position in the map
position(0..cols*rows-1).

% Contain in the cells
contain(water; land).
