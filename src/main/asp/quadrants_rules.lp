% Rafael Alcalde Azpiazu - 2 Apr 2018
% Facultade de Informática da Coruña - Universidade da Coruña
%
% This file defines how the quadrants are created, with rules and
% restrictions, in order to create regions in the map.
%

% Generates the root of the quadrant
1 { q_root(C, I): q_pos(C) } 1 :- region(I).
:- q_root(C, I), q_root(C, J), I!=J.

% A cell is reached if is the rootcell of the island or if the cell
% can reach the rootcell
q_reached(C, I) :- q_root(C, I).
0 {q_reached(C, I)} 1 :- q_reached(D, I), region(I), not existsanother(J, I, C), region(J), q_adj(D, C).
existsanother(J, I, C) :- q_reached(C, J), region(I), J!=I.

% Definition of array adjacent cell
q_adj(C, C-1) :- q_pos(C), C \ q_cols > 0.
q_adj(C, C+1) :- q_pos(C), C \ q_cols < q_cols-1.
q_adj(C, C+q_cols) :- q_pos(C), C < q_cols*(q_rows-1).
q_adj(C, C-q_cols) :- q_pos(C), C >= q_cols.

quadrant(C, I) :- q_reached(C, I).
% :- not 2 { q_reached(C, 1) }.
