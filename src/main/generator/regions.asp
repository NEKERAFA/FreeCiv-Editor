% Rafael Alcalde Azpiazu - 2 Apr 2018
% Facultade de Informática da Coruña - Universidade da Coruña
%
% This file defines how the quadrants are created, like rules and
% restrictions, in order to create regions in the map.
%

% Generates the root of the quadrant
1 { root(C, I): position(C) } 1 :- island(I).
:- root(C, I), root(C, J), I!=J.

% A cell is reached if is the rootcell of the island or if the cell
% can reach the rootcell
reached(C, I) :- root(C, I).
0 {reached(C, I)} 1 :- reached(D, I), not existsanother(J, I, C), island(J), adjacent(D, C).
existsanother(J, I, C) :- reached(C, J), island(I), J!=I.

% Definition of adjacent
adjacent(C, C-1) :- position(C), C \ cols > 0.
adjacent(C, C+1) :- position(C), C \ cols < cols-1.
adjacent(C, C+cols) :- position(C), C < cols*(rows-1).
adjacent(C, C-cols) :- position(C), C >= cols.

cell(C, I) :- reached(C, I).

% :- not 20 { reached(C, I) }.
