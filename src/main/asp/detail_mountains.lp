% Type of row and columns
row(0..ROWS-1) :- dims(ROWS, COLS, SIZE).
col(0..COLS-1) :- dims(ROWS, COLS, SIZE).

% Definition of position
pos(p(X, Y)) :- row(X), col(Y).

% Generate the start and the end position
1 {start(P) : cell(P, l)} 1.
1 {end(P) : cell(P, l)} 1 :- start(Q).
% Forbidden that start and end point are the same.
:- start(P), end(Q), P==Q.

% The start cell is reached always.
reached(P) :- start(P).
% A cell next to a reached cell could be reached
{reached(P)} :- cell(P, l), reached(Q), adj(P, Q).

% Definition of array adjacent cell
adj(p(X, Y), p(X, Y+1)) :- pos(p(X, Y)), pos(p(X, Y+1)).
adj(p(X, Y), p(X+1, Y)) :- pos(p(X, Y)), pos(p(X+1, Y)).
adj(P, Q) :- adj(Q, P).

% The path is complete if the end is reached.
complete :- end(P), reached(P).
% Forbidden the paths that don't reach the end point.
:- start(P), not complete.

% Count the number of neighbour cells reached.
size(p(X, Y), up, 0) :- reached(p(X, Y)), not reached(p(X-1, Y)).
size(p(X, Y), up, N+1) :- reached(p(X, Y)), size(p(X-1, Y), up, N).
size(p(X, Y), down, 0) :- reached(p(X, Y)), not reached(p(X+1, Y)).
size(p(X, Y), down, N+1) :- reached(p(X, Y)), size(p(X+1, Y), down, N).
size(p(X, Y), left, 0) :- reached(p(X, Y)), not reached(p(X, Y-1)).
size(p(X, Y), left, N+1) :- reached(p(X, Y)), size(p(X, Y-1), left, N).
size(p(X, Y), right, 0) :- reached(p(X, Y)), not reached(p(X, Y+1)).
size(p(X, Y), right, N+1) :- reached(p(X, Y)), size(p(X, Y+1), right, N).

% Count the height and the width of a cell basing of the number of conected
% neighbours
height(P, N+M+1) :- size(P, up, N), size(P, down, M).
width(P, N+M+1) :- size(P, left, N), size(P, right, M).

% Forbidden paths smaller than the defined size in dims atom.
:- height(P, N), dims(ROWS, COLS, SIZE), N!=SIZE.
:- width(P, N), dims(ROWS, COLS, SIZE), N!=SIZE.

% Translate reached in mountain atom.
mountain(P) :- reached(P).
