% Type of row and columns
row(0..ROWS-1) :- dims(ROWS, COLS, TERRAIN).
col(0..COLS-1) :- dims(ROWS, COLS, TERRAIN).

ice(ROWS*10/100) :- dims(ROWS, COLS, TERRAIN).

% Definition of position
pos(p(X, Y)) :- row(X), col(Y).

% Type of lands
types(plain; hills; forest; jungle; trunda; swamp; desert; glacier).
biomas(plain; hills; forest; jungle; trunda; swamp; desert).

% Number of cells
max_cells(MAX) :- #count{P : cell(P, l)} = MAX.

% Generate glacier regions
%reached(p(X, Y), glacier) :- cell(p(X, Y), l), ice(N), X <= N.
%reached(p(X, Y), glacier) :- cell(p(X, Y), l), ice(N), dims(ROWS, COLS), X >= ROWS-N-1.
%n_ice(N) :- #count{P : reached(P, glacier)} = N.

% The root of a bioma
0 { root(P, T) : cell(P, l) } 1 :- biomas(T).
:- root(P, T), root(P, U), T!=U.

reached(P, T) :- root(P, T).
{ reached(P, T) } :- biomas(T), cell(P, l), adj(P, Q), reached(Q, T).
:- reached(P, T), reached(P, U), T!=U.

% Definition of array adjacent cell
adj(p(X, Y), p(X, Y+1)) :- pos(p(X, Y)), pos(p(X, Y+1)).
adj(p(X, Y), p(X+1, Y)) :- pos(p(X, Y)), pos(p(X+1, Y)).
adj(P, Q) :- adj(Q, P).

% Preference in the size of regions
n_cells(Z) :- #count{C, I : reached(C, I)} = Z.

:- n_cells(Z), max_cells(MAX), dims(ROWS, COLS, TERRAIN), Z!=MAX*TERRAIN/100.

% Gets the number of root cells
roots(N) :- #count{P, T: root(P, T)} = N.
:- roots(N), N < 1.

% Gets the size of biomas
size_bioma(T, N) :- root(Q, T), cell(Q, l), #count{P: reached(P, T)} = N.
:- size_bioma(T, N), N < 2.

% Translate quadrant reached in a quadrant
land(P, T) :- reached(P, T).

% 1 {land(P, T) : types(T)} 1 :- cell(P, l).
