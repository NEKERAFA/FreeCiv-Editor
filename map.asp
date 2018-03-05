% Rafael Alcalde Azpiazu - 31 Jan 2018
% Facultade de Informática da Coruña - Universidade da Coruña
%
% This file describes how is the playable map, defining all the cells in the map
% and which they contain
%
% Edited on 19 Feb 2018 - 18:15
% Edited on 18 Feb 2018 - 17:56

% #show cell/2.

% Constants
#const rows = 10.
#const cols = 20.
#const islands = 4.

% Types
% Position in the map
position(0..cols*rows-1).

% Contain in the cells
land(grass; hills; desert; forest; plains).
water(ocean; lake; deepocean).
contain(C) :- land(C).
contain(C) :- water(C).

% Definition of islands
island(1..islands).
