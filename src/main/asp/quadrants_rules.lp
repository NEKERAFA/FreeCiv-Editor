% Rafael Alcalde Azpiazu - 2 Apr 2018
% Facultade de Informática da Coruña - Universidade da Coruña
%
% This file defines how the quadrants are created, with rules and
% restrictions, in order to create regions in the map.
%

% Generates the root of the quadrant
1 { quadrant_root(C, I): quadrant_position(C) } 1 :- island(I).
:- quadrant_root(C, I), quadrant_root(C, J), I!=J.

% A cell is reached if is the rootcell of the island or if the cell
% can reach the rootcell
quadrant(C, I) :- quadrant_root(C, I).
0 {quadrant(C, I)} 1 :- quadrant(D, I), not existsanother(J, I, C), island(J), adjacent(D, C).
existsanother(J, I, C) :- quadrant(C, J), island(I), J!=I.

% Definition of adjacent
adjacent(C, C-1) :- quadrant_position(C), quadrants(ROWS, COLS), C \ COLS > 0.
adjacent(C, C+1) :- quadrant_position(C), quadrants(ROWS, COLS), C \ COLS < COLS-1.
adjacent(C, C+COLS) :- quadrant_position(C), quadrants(ROWS, COLS), C < COLS*(ROWS-1).
adjacent(C, C-COLS) :- quadrant_position(C), quadrants(ROWS, COLS), C >= COLS.

% cell(C, I) :- reached(C, I).
% :- not 20 { reached(C, I) }.
