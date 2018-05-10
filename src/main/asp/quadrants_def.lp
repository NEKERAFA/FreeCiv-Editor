% Rafael Alcalde Azpiazu - 2 Apr 2018
% Facultade de Informática da Coruña - Universidade da Coruña
%
% This file defines the types which are used to generates the
% quadrants in the map.
%

%%%% CONSTANTS
#const q_rows = 2.
#const q_cols = 3.
#const regions = 2.

%%%% TYPES
% Type of row and columns
q_row(0..q_rows).
q_col(0..q_cols).

% The position of the quadrant in the map
q_pos(0..q_rows*q_cols-1).

% The identifier of the region in the map
region(0..regions-1).

% To translate a quadrant array position to 2-d position
xypos(P, X, Y) :- q_pos(P), q_row(X), q_col(Y), X = P \ q_cols, Y = P / q_cols.
