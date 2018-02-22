% Rafael Alcalde Azpiazu - 31 Jan 2018
% Facultade de Informática da Coruña - Universidade da Coruña
%
% This file describes how is the playable map, defining all the cells in the map
% and which they contain
%
% Edited on 19 Feb 2018 - 18:15

#show cell/2.

% Constants
#const rows = 30.
#const cols = 40.

% Types
% Position in the map
position(0..cols*rows-1).
% Contain in the cells
land(grass; hills; desert; forest; plains).
contain(C) :- land(C).
contain(ocean).

% Generator rule of all cells
1 {cell(C,N) : contain(N)} 1 :- position(C).
