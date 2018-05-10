% Rafael Alcalde Azpiazu - 2 Apr 2018
% Facultade de Informática da Coruña - Universidade da Coruña
%
% This file defines how the quadrants are created, with rules and
% restrictions, in order to create regions in the map.
%

% This program generates a cell
#program generate(i).
  % Generates all the positions in the region i
  c_pos(p(X, Y)) :- quadrant(P, i), xypos(P, R, C), c_row(X), X >= R*c_rows, X < (R+1)*c_rows, c_col(Y), Y >= C*c_cols, Y < (C+1)*c_cols.

  % Generates a rootcell
  1 {rootcell(P) : c_pos(P)} 1.

  % Gets the cells reached for create the island
  reached(P) :- rootcell(P).
  reached(P) :- reached(Q), adj(Q, P).

  % Definition of matrix adjacent cell
  adj(p(X, Y), p(X, Y+1)) :- c_pos(p(X, Y)), c_pos(p(X, Y+1)).
  adj(p(X, Y), p(X+1, Y)) :- c_pos(p(X, Y)), c_pos(p(X+1, Y)).
  adj(P, Q) :- adj(Q, P).

  % Sets land and ocean
  cell(P, l) :- ipos(P, X, Y), reached(p(X, Y)).
