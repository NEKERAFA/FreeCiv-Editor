% Rafael Alcalde Azpiazu - 05 Feb 2018
% Facultade de Informática da Coruña - Universidade da Coruña
%
% This file describes how is the playable map, defining all the cells in the map
% and which they contain
%
% Edited on 21 Mar 2018 - 16:34
%

% Generates a rootcell
1 { rootcell(C) : position(C) } 1.

% Generates the extension of the island
reached(C) :- rootcell(C).
reached(C) :- reached(D), adjacent(C, D), rootcell(D).
0 { reached(C) } 1 :- reached(D), adjacent(C, D).

% Adjacent definition
adjacent(C, C-1) :- position(C), C \ cols > 0.
adjacent(C, C+1) :- position(C), C \ cols < cols-1.
adjacent(C, C+cols) :- position(C), C < cols*(rows-1).
adjacent(C, C-cols) :- position(C), C >= cols.

% Fills the cell with a contain
1 {cell(C, N) : land(N)} 1 :- reached(C).
cell(C, ocean) :- position(C), not reached(C), adjacent(C, D), reached(D).
cell(C, deepocean) :- position(C), not cell(C, ocean), not cell(C, N), land(N).
