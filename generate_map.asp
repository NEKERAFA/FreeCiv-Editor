% Rafael Alcalde Azpiazu - 05 Feb 2018
% Facultade de Informática da Coruña - Universidade da Coruña
%
% This file adds all the restrictions in order to create a map that the player
% and the IA of Freeciv could cross
%
% Edited on 19 Feb 2018 - 18:20

#show rootcell/1.
%#show reached/2.

% Generates a root cell in order to create a island
1 {rootcell(C): position(C)} 1.
cell(C, N): land(N) :- rootcell(C).

% This rules creates a island
reached(C) :- rootcell(C).
reached(C) :- reached(D), cell(C, N), land(N), adjacent(C, D).
:- cell(C, N), position(C), land(N), not reached(C).

% Definition of adjacent cells
adjacent(C, C-1) :- position(C), C \ cols > 0.
adjacent(C, C+1) :- position(C), C \ cols < cols-1.
adjacent(C, C+cols) :- position(C), C < (rows-1)*cols.
adjacent(C, C-cols) :- position(C), C >= cols.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Constants
%#const max_islands = 3.

%islands(1..max_islands).

% Generates a root cell in order to create a island
%max_islands {rootcell(C, I) : C=0..cols*rows-1, I=1..max_islands} max_islands.
%cell(C, N): land(N) :- rootcell(C, I), islands(I).
%:- rootcell(C, I), rootcell(D, J), C!=D, I==J.

% This rules creates a island
%reached(C, I) :- rootcell(C, I).
%reached(C, I) :- reached(D, I), cell(C, N), land(N), adjacent(C, D).
% Restriction to set not reachable cell like not walkable cell.
%:- cell(C, N), land(N), not reached(C, I), I=1..max_islands.
% Restriction to set island cell with cells adjacent
%:- reached(C, I), reached(D, J), I=1..max_islands, J=1..max_islands, adjacent(C, D).
