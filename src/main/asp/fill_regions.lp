% Type of row and columns
c_row(0..ROWS-1) :- dims(ROWS, COLS, LAND).
c_col(0..COLS-1) :- dims(ROWS, COLS, LAND).
c_index(0..ROWS*COLS-1) :- dims(ROWS, COLS, LAND).

% To translate cell 2-d postion to array position
ipos(P, R, C) :- P = R*COLS+C, c_index(P), c_row(R), c_col(C), dims(ROWS, COLS, LAND).

% To translate a quadrant array position to 2-d position
xypos(P, X, Y) :- q_pos(P), q_row(X), q_col(Y), X = P \ Q_COLS, Y = P / Q_COLS,
  q_dims(Q_ROWS, Q_COLS).

% This program generates a cell
#program generate(i).
  % Generates all the positions in the region i
  c_pos(p(X, Y)) :- quadrant(P, i), xypos(P, R, C), c_row(X), X >= R*C_ROWS,
    X < (R+1)*C_ROWS, c_col(Y), Y >= C*C_COLS, Y < (C+1)*C_COLS,
    c_dims(C_ROWS, C_COLS).

  % Definition of matrix adjacent cell
  adj(p(X, Y), p(X, Y+1)) :- c_pos(p(X, Y)), c_pos(p(X, Y+1)).
  adj(p(X, Y), p(X+1, Y)) :- c_pos(p(X, Y)), c_pos(p(X+1, Y)).
  adj(P, Q) :- adj(Q, P).

  % Number of cells in the region
  n_cells(Z) :- #count{P: c_pos(P)}=Z.

  % Generates a rootcell
  1 {rootcell(P) : c_pos(P)} 1.

  % Gets the cells reached for create the island
  reached(P) :- rootcell(P).
  {reached(P)} :- reached(Q), adj(Q, P).

  % Gets the neighbours
  top(p(X, Y), l) :- c_pos(p(X, Y)), c_pos(p(X-1, Y)), reached(p(X-1, Y)).
  top(p(X, Y), w) :- c_pos(p(X, Y)), c_pos(p(X-1, Y)), not reached(p(X-1, Y)).
  top(p(X, Y), b) :- c_pos(p(X, Y)), not c_pos(p(X-1, Y)).

  bottom(p(X, Y), l) :- c_pos(p(X, Y)), c_pos(p(X+1, Y)), reached(p(X+1, Y)).
  bottom(p(X, Y), w) :- c_pos(p(X, Y)), c_pos(p(X+1, Y)), not reached(p(X+1, Y)).
  bottom(p(X, Y), b) :- c_pos(p(X, Y)), not c_pos(p(X+1, Y)).

  right(p(X, Y), l) :- c_pos(p(X, Y)), c_pos(p(X, Y-1)), reached(p(X, Y-1)).
  right(p(X, Y), w) :- c_pos(p(X, Y)), c_pos(p(X, Y-1)), not reached(p(X, Y-1)).
  right(p(X, Y), b) :- c_pos(p(X, Y)), not c_pos(p(X, Y-1)).

  left(p(X, Y), l) :- c_pos(p(X, Y)), c_pos(p(X, Y+1)), reached(p(X, Y+1)).
  left(p(X, Y), w) :- c_pos(p(X, Y)), c_pos(p(X, Y+1)), not reached(p(X, Y+1)).
  left(p(X, Y), b) :- c_pos(p(X, Y)), not c_pos(p(X, Y+1)).

  % Forbidden create lakes with 1 cell
  :- c_pos(P), not reached(P), top(P, T), T!=w, left(P,L), L!=w, bottom(P,B), B!=w, right(P,R), R!=w.

  % Forbidden create bridges
  :- reached(P), top(P, w), left(P, L), L!=w, bottom(P, w), right(P, R), R!=w.
  :- reached(P), top(P, T), T!=w, left(P, w), bottom(P, B), B!=w, right(P,w).

  % Preference in the size of islands in relation to the size of the region
  cells_reached(Z) :- #count{P: reached(P)}=Z.
  :- cells_reached(Z), n_cells(MAX), dims(ROWS, COLS, LAND), Z!=MAX*LAND/100.

  % Sets land and ocean
  cell(P, l) :- reached(P).
  cell(P, w) :- c_pos(P), not reached(P).
