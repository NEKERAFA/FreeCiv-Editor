% Type of row and columns
c_row(0..ROWS-1) :- dims(ROWS, COLS).
c_col(0..COLS-1) :- dims(ROWS, COLS).
c_index(0..ROWS*COLS-1) :- dims(ROWS, COLS).

% To translate cell 2-d postion to array position
ipos(P, R, C) :- P = R*COLS+C, c_index(P), c_row(R), c_col(C), dims(ROWS, COLS).

% To translate a quadrant array position to 2-d position
xypos(P, X, Y) :- q_pos(P), q_row(X), q_col(Y), X = P \ Q_COLS, Y = P / Q_COLS,
  q_dims(Q_ROWS, Q_COLS).

% This program generates a cell
#program generate(i).
  % Generates all the positions in the region i
  c_pos(p(X, Y)) :- quadrant(P, i), xypos(P, R, C), c_row(X), X >= R*C_ROWS,
    X < (R+1)*C_ROWS, c_col(Y), Y >= C*C_COLS, Y < (C+1)*C_COLS,
    c_dims(C_ROWS, C_COLS).

  % Generates all the borders and positions in the region i
  pos(p(X, Y)) :- quadrant(P, i), xypos(P, R, C), c_row(X), X >= R*C_ROWS-1,
    X <= (R+1)*C_ROWS, c_col(Y), Y >= C*C_COLS-1, Y <= (C+1)*C_COLS,
    c_dims(C_ROWS, C_COLS).

  % Definition of matrix adjacent cell
  adj(p(X, Y), p(X, Y+1)) :- pos(p(X, Y)), pos(p(X, Y+1)).
  adj(p(X, Y), p(X+1, Y)) :- pos(p(X, Y)), pos(p(X+1, Y)).
  adj(P, Q) :- adj(Q, P).

  % Get de borders
  border(P) :- pos(P), not c_pos(P), adj(P, Q), pos(Q), c_pos(Q), land(Q).

  % Number of cells in the region
  n_cells(Z) :- #count{P: c_pos(P)}=Z.
  % The minimun number of cells in the region
  min_cells(N/2) :- n_cells(N).

  % Generates a rootcell
  1 {rootcell(P) : c_pos(P)} 1.
  :- rootcell(P), border(Q).

  % Gets the cells reached for create the island
  reached(P) :- rootcell(P).
  {reached(P)} :- reached(Q), adj(Q, P), c_pos(P), not border(P).

  % Preference in the size of islands in relation to the size of the region
  cells_reached(Z) :- #count{P: reached(P)}=Z.
  :- cells_reached(Z), min_cells(MIN), Z < MIN.

  % Sets land and ocean
  cell(P, l) :- ipos(P, X, Y), reached(p(X, Y)).
