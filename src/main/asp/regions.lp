%%%% CONSTANTS
#const q_rows = 3.
#const q_cols = 3.
#const regions = 2.
#const c_rows = 4.
#const c_cols = 4.
#const rows = q_rows*c_rows.
#const cols = q_cols*c_cols.

#const c_min = 25.
#const c_max = 100.
#const q_min = 25.
#const q_max = 100.

#program base().
  %%%% TYPES
  % Type of row and columns
  q_row(0..q_rows).
  q_col(0..q_cols).

  % The position of the quadrant in the map
  q_pos(0..q_rows*q_cols-1).

  % The identifier of the region in the map
  region(0..regions-1).

  % The maximun and minimun number of quadrants in the map
  max_quadrants(q_rows*q_cols*q_max/100).
  min_quadrants(q_rows*q_cols*q_min/100).

  % Type of row and columns
  c_row(0..rows-1).
  c_col(0..cols-1).
  c_index(0..rows*cols-1).

  % The type of terrain of the cell on the map
  land(o; l).

  % To translate cell 2-d postion to array position
  ipos(P, R, C) :- P = R*cols+C, c_index(P), c_row(R), c_col(C).
  % To translate a quadrant array position to 2-d position
  xypos(P, X, Y) :- q_pos(P), q_row(X), q_col(Y), X = P \ q_cols, Y = P / q_cols.

  % Generates the root of the quadrant
  1 { q_root(C, I): q_pos(C) } 1 :- region(I).
  :- q_root(C, I), q_root(C, J), I!=J.

  % A cell is reached if is the rootcell of the island or if the cell
  % can reach the rootcell
  q_reached(C, I) :- q_root(C, I).
  {q_reached(C, I)} :- q_reached(D, I), region(I), not existsanother(J, I, C), region(J), q_adj(D, C).
  existsanother(J, I, C) :- q_reached(C, J), region(I), J!=I.

  % Definition of array adjacent cell
  q_adj(C, C-1) :- q_pos(C), C \ q_cols > 0.
  q_adj(C, C+1) :- q_pos(C), C \ q_cols < q_cols-1.
  q_adj(C, C+q_cols) :- q_pos(C), C < q_cols*(q_rows-1).
  q_adj(C, C-q_cols) :- q_pos(C), C >= q_cols.

  % Preference in the size of regions
  n_quadrants(Z) :- #count{C, I: q_reached(C,I)}=Z.
  :- n_quadrants(Z), max_quadrants(MAX), Z > MAX.
  :- n_quadrants(Z), min_quadrants(MIN), Z < MIN.

  % Translate quadrant reached in a quadrant
  quadrant(C, I) :- q_reached(C, I).
