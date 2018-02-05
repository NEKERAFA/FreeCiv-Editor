% Rafael Alcalde Azpiazu - 31 Jan 2018
% Facultade de Informática da Coruña - Universidade da Coruña
%
% This file describes how is the playable map, defining all the cells in the map
% and which they contain

#show cell/3.

% Constants
#const rows = 10.
#const columns = 20.

% Types
row(1..rows).
column(1..columns).
contain(grass).
start(1,1).
finish(rows,columns).
move(1,0 ;; -1,0 ;; 0,1 ;; 0,-1).
3*rows*columns/5 {cell(X,Y,C) : contain(C), row(X), column(Y)}.
