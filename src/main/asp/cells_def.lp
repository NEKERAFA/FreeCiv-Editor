% Rafael Alcalde Azpiazu - 26 Apr 2018
% Facultade de Informática da Coruña - Universidade da Coruña
%
% This file defines the types which are used to generates the
% cells in the map.
%

%%%% CONSTANTS
#const c_rows = 3.
#const c_cols = 3.

#const rows = q_rows*c_rows.
#const cols = q_cols*c_cols.

%%%% TYPES
% Type of row and columns
c_row(0..rows-1).
c_col(0..cols-1).
c_index(0..rows*cols-1).

% The type of terrain of the cell on the map
land(o; l).

% To translate cell 2-d postion to array position
ipos(P, R, C) :- P = R*cols+C, c_index(P), c_row(R), c_col(C).
