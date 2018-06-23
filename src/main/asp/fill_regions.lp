%%%% CONSTANST
% #const c_rows = 4.
% #const c_cols = 4.
% #const rows = q_rows*c_rows.
% #const cols = q_cols*c_cols.
%
% #const c_min = 25.
% #const c_max = 100.

% Type of row and columns
c_row(0..ROWS-1) :- dims(ROWS, COLS).
c_col(0..COLS-1) :- dims(ROWS, COLS).
c_index(0..ROWS*COLS-1) :- dims(ROWS, COLS).

% To translate cell 2-d postion to array position
ipos(P, R, C) :- P = R*COLS+C, c_index(P), c_row(R), c_col(C), dims(ROWS, COLS).

% To translate a quadrant array position to 2-d position
xypos(P, X, Y) :- q_pos(P), q_row(X), q_col(Y), X = P \ Q_COLS,
 Y = P / Q_COLS, q_dims(Q_ROWS, Q_COLS).

% This program generates a cell
#program generate(i).
  % Generates all the positions in the region i
  c_pos(p(X, Y)) :- quadrant(P, i), xypos(P, R, C), c_row(X), X >= R*C_ROWS,
   X < (R+1)*C_ROWS, c_col(Y), Y >= C*C_COLS, Y < (C+1)*C_COLS,
   c_dims(C_ROWS, C_COLS).

  % Number of cells in the region
  n_cells(Z) :- #count{P: c_pos(P)}=Z.
  % The maximun and minimun number of cells in the region
  max_cells(N) :- n_cells(N).
  min_cells(N/2) :- n_cells(N).

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
  cells_reached(Z) :- #count{P: reached(P)}=Z.
  %:- cells_reached(Z), n_cells(N), Z!=N.
  :- cells_reached(Z), max_cells(MAX), Z > MAX. %[1]
  :- cells_reached(Z), min_cells(MIN), Z < MIN. %[1]

  % tam(Z) :- #count{X:cell(X,l)}=Z.
  % :- tam(Z),Z>8.
  % :- tam(Z),Z<4.

  % Sets land and ocean
  cell(P, l) :- ipos(P, X, Y), reached(p(X, Y)).
