% Rafael Alcalde Azpiazu - 31 Jan 2018
% This file describes how is the playable map, defining all the cells in the map
% and which they contain

#show cell/3.

% Constants
#const rows = 10.
#const columns = 20.

% Types
row(1..rows).
column(1..columns).
contain(water).
contain(grass).
start(1,1).
finish(10,20).
step(1,0 ;; -1,0 ;; 0,1 ;; 0,-1).

% Restrictions
1{cell(X,Y,C) : contain(C)}1 :- row(X), column(Y).
