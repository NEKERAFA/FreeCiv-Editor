% Rafael Alcalde Azpiazu - 31 Jan 2018
% Facultade de Informática da Coruña - Universidade da Coruña
%
% This file defines the values to create a chunk
%
% Edited on 19 Feb 2018 - 18:15
% Edited on 18 Feb 2018 - 17:56
% Edited on 12 Mar 2018 - 12:53

%%%% CONSTANTS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#const rows = 8.
#const cols = 8.

%%%% TYPES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Position in the map
position(0..cols*rows-1).

% Contain in the cells
land(grass; hills; desert; forest; plains).
water(ocean; deepocean).
contain(C) :- land(C).
contain(C) :- water(C).
