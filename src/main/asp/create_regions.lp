%%%% CONSTANTS
#const q_rows = 3.
#const q_cols = 3.
#const c_rows = 4.
#const c_cols = 4.
#const regions = 2.

#program base.

%%%% TYPES
% Type of row and columns
q_row(0..q_rows).
q_col(0..q_cols).

% The position of the quadrant in the map
q_pos(0..q_rows*q_cols-1).

% The identifier of the region in the map
region(0..regions-1).

% The maximun number of quadrants in the map
max_quadrants(q_rows*q_cols).

% Generates the root of the quadrant
1 { q_root(C, I): q_pos(C) } 1 :- region(I).
:- q_root(C, I), q_root(C, J), I!=J.

% A cell is reached if is the rootcell of the island or if the cell
% can reach the rootcell
q_reached(C, I) :- q_root(C, I).
{q_reached(C, I)} :- q_reached(D, I), region(I), not existsanother(I, C), q_adj(D, C).
existsanother(I, C) :- q_reached(C, J), region(J), region(I), J!=I.

% Definition of array adjacent cell
q_adj(C, C-1) :- q_pos(C), C \ q_cols > 0.
q_adj(C, C+1) :- q_pos(C), C \ q_cols < q_cols-1.
q_adj(C, C+q_cols) :- q_pos(C), C < q_cols*(q_rows-1).
q_adj(C, C-q_cols) :- q_pos(C), C >= q_cols.

% Preference in the size of regions
n_quadrants(Z) :- #count{C, I: q_reached(C,I)}=Z.
:~ n_quadrants(Z), max_quadrants(MAX), Z!=MAX. [1]

% Translate quadrant reached in a quadrant
quadrant(C, I) :- q_reached(C, I).
