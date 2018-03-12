% Rafael Alcalde Azpiazu - 05 Feb 2018
% Facultade de Informática da Coruña - Universidade da Coruña
%
% This file adds all the restrictions in order to create a map that the player
% and the IA of Freeciv could cross
%
% Edited on 19 Feb 2018 - 18:20
% Edited on 28 Feb 2018 - 18:15

% #show reached/2.

% Generates the root cell of the island
1 { rootcell(C, I): position(C) } 1 :- island(I).
:- rootcell(C, I), rootcell(C, J), I != J.

% Generates
reached(C, I) :- rootcell(C, I).
0 {reached(C, I)} 1 :- reached(D, I), adjacent(C, D).
:- reached(C, I), reached(C, J), I != J.

adjacent(C, C-1) :- position(C), C \ cols > 0.
adjacent(C, C+1) :- position(C), C \ cols < cols-1.
adjacent(C, C+cols) :- position(C), C < cols*(rows-1).
adjacent(C, C-cols) :- position(C), C >= cols.

1 { cell(C, N): land(N) } 1 :- reached(C, I).
cell(C, ocean) :- position(C), not reached(C, I), island(I).

:- not 40 { cell(C, N): land(N), position(C) } 40.
