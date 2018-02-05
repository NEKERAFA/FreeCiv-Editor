% Rafael Alcalde Azpiazu - 05 Feb 2018
% Facultade de Informática da Coruña - Universidade da Coruña
%
% This file adds all the restrictions in order to create a map that the player
% and the IA of Freeciv could cross

#show reached/2.

% Constants
#const length=30.

% Definitions
% A walkable cell is a cell with grass
walkable(X,Y) :- cell(X,Y,C).

% Definition of reachability in the map
reached(X,Y) :- start(X,Y), walkable(X,Y).
reached(X1,Y1) :- reached(X2,Y2), move(DX,DY), X1=X2+DX, Y1=Y2+DY, walkable(X2,Y2).

% Definition of step in the map
step(X,Y,0) :- start(X,Y), walkable(X,Y).
step(X1,Y1,S) :- step(X2,Y2,S-1), S < length, walkable(X1,Y1), move(DX,DY), X1=X2+DX, Y1=Y2+DY.

% Restrictions
% The walk is complete if finish is reached
walk :- finish(X,Y), reached(X,Y).
:- not walk.

% Forbid a walk from start to finish cell if the walk length is less that the defined length
walk_len :- finish(X,Y), step(X,Y,length).
:- walk_len.
