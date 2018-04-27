% Rafael Alcalde Azpiazu - 26 Apr 2018
% Facultade de Informática da Coruña - Universidade da Coruña
%
% This file defines the types which are used to generates the
% cells in the map.
%

%%%% TYPES
% Number of rows and columns of cells in a quadrant
cells(3, 3).

% The position of the quadrant in the map
cell_position(0..N) :- cells(R, C), N = R*C-1.

% The type of terrain of the cell on the map
terrain(o; l).
