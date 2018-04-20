% Rafael Alcalde Azpiazu - 2 Apr 2018
% Facultade de Informática da Coruña - Universidade da Coruña
%
% This file defines the types which are used to generates the
% quadrants in the map.
%

%%%% CONSTANTS
% Number of rows and columns in the file
#const rows = 2.
#const cols = 3.
% Number of islands
#const islands = 2.

%%%% TYPES
% The position of the quadrant in the map
position(0..cols*rows-1).

% The identifier of the island in the map
island(0..islands-1).
