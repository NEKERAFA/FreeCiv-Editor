% Rafael Alcalde Azpiazu - 2 Apr 2018
% Facultade de Informática da Coruña - Universidade da Coruña
%
% This file defines the types which are used to generates the
% quadrants in the map.
%

%%%% TYPES
% Number of rows and columns of quadrants in the map
quadrants(2, 3).

% Number of islands
islands(2).

% The position of the quadrant in the map
quadrant_position(0..N) :- quadrants(R, C), N = R*C-1.

% The identifier of the island in the map
island(0..N) :- islands(N+1).
