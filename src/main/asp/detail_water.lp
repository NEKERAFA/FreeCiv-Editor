% dims(6, 6).

%-------------------------------------------------------------------------------
%cell(p(0, 0), w).
%cell(p(0, 1), l).
%cell(p(0, 2), l).
%cell(p(0, 3), l).
%cell(p(0, 4), w).
%cell(p(0, 5), w).
%-------------------------------------------------------------------------------
%cell(p(1, 0), w).
%cell(p(1, 1), w).
%cell(p(1, 2), l).
%cell(p(1, 3), w).
%cell(p(1, 4), w).
%cell(p(1, 5), w).
%-------------------------------------------------------------------------------
%cell(p(2, 0), w).
%cell(p(2, 1), w).
%cell(p(2, 2), w).
%cell(p(2, 3), w).
%cell(p(2, 4), w).
%cell(p(2, 5), w).
%-------------------------------------------------------------------------------
%cell(p(3, 0), w).
%cell(p(3, 1), w).
%cell(p(3, 2), w).
%cell(p(3, 3), w).
%cell(p(3, 4), w).
%cell(p(3, 5), w).
%-------------------------------------------------------------------------------
%cell(p(4, 0), w).
%cell(p(4, 1), l).
%cell(p(4, 2), l).
%cell(p(4, 3), w).
%cell(p(4, 4), w).
%cell(p(4, 5), w).
%-------------------------------------------------------------------------------
%cell(p(5, 0), w).
%cell(p(5, 1), l).
%cell(p(5, 2), l).
%cell(p(5, 3), w).
%cell(p(5, 4), w).
%cell(p(5, 5), l).
%-------------------------------------------------------------------------------


% Type of row and columns
row(0..ROWS-1) :- dims(ROWS, COLS).
col(0..COLS-1) :- dims(ROWS, COLS).

% Definition of position
pos(p(X, Y)) :- row(X), col(Y).

% Definition of matrix adjacent cell
adj(p(X, Y), p(X, Y+1)) :- pos(p(X, Y)), pos(p(X, Y+1)).
adj(p(X, Y), p(X+1, Y)) :- pos(p(X, Y)), pos(p(X+1, Y)).
adj(p(X, Y), p(X+1, Y+1)) :- pos(p(X, Y)), pos(p(X+1, Y+1)).
adj(p(X, Y), p(X+1, Y-1)) :- pos(p(X, Y)), pos(p(X+1, Y-1)).
adj(P, Q) :- adj(Q, P).

% Draw sea if there are near land
water(P, sea) :- cell(P, w), adj(P, Q), cell(Q, l).
% Draw ocean if there are near sea or near ocean
water(P, ocean) :- cell(P, w), adj(P, Q), water(Q, sea), not arround_land(P).
water(P, ocean) :- cell(P, w), adj(P, Q), water(Q, ocean), not arround_land(P).

% Checks if a cell of water is near a cell of land
arround_land(P) :- cell(P, w), adj(P, Q), cell(Q, l).
