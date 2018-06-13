% This program generates a cell
#program generate(i).
  % Generates all the positions in the region i
  c_pos(p(X, Y)) :- quadrant(P, i), xypos(P, R, C), c_row(X), X >= R*c_rows, X < (R+1)*c_rows, c_col(Y), Y >= C*c_cols, Y < (C+1)*c_cols.

  % Number of cells in the region
  n_cells(Z) :- #count{P: c_pos(P)}=Z.

  % The maximun and minimun number of cells in the region
  max_cells(N*c_max/100) :- n_cells(N).
  min_cells(N*c_min/100) :- n_cells(N).

  % Generates a rootcell
  1 {rootcell(P) : c_pos(P)} 1.

  % Gets the cells reached for create the island
  reached(P) :- rootcell(P).
  {reached(P)} :- reached(Q), adj(Q, P).

  % Definition of matrix adjacent cell
  adj(p(X, Y), p(X, Y+1)) :- c_pos(p(X, Y)), c_pos(p(X, Y+1)).
  adj(p(X, Y), p(X+1, Y)) :- c_pos(p(X, Y)), c_pos(p(X+1, Y)).
  adj(P, Q) :- adj(Q, P).

  % Preference in the size of islands in relation to the size of the region
  cells_reached(Z) :- #count{P: q_reached(P, i)}=Z.
  :~ cells_reached(Z), max_cells(MAX), Z > MAX. [1]
  :~ cells_reached(Z), min_cells(MIN), Z < MIN. [1]

  % tam(Z) :- #count{X:cell(X,l)}=Z.
  % :- tam(Z),Z>8.
  % :- tam(Z),Z<4.

  % Sets land and ocean
  cell(P, l) :- ipos(P, X, Y), reached(p(X, Y)).
