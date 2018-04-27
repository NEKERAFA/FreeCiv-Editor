% Rafael Alcalde Azpiazu - 2 Apr 2018
% Facultade de Informática da Coruña - Universidade da Coruña
%
% This file defines how the quadrants are created, with rules and
% restrictions, in order to create regions in the map.
%

% Defines if the regionof the current quadrant continues in a neightbour quadrant
region_continues(upper; left).

% Generate the terrain in the map
1 { cell(C, T) : terrain(T) } 1 :- cell_position(C).

% Checks where the terrain must continue
:- cell(C, o), region_continues(upper), upper_cell(C).
:- cell(C, o), region_continues(bottom), bottom_cell(C).
:- cell(C, o), region_continues(left), left_cell(C).
:- cell(C, o), region_continues(right), right_cell(C).
:- cell(0, o), region_upperleft.
:- cell(COLS-1, o), region_upperright, cells(ROWS, COLS).
:- cell((ROWS-1)*COLS, o), region_bottomleft, cells(ROWS, COLS).
:- cell(ROWS*COLS-1, o), region_bottomright, cells(ROWS, COLS).

% Checks where the terrain must not continue
:- cell(C, l), not region_continues(upper), upper_cell(C).
:- cell(C, l), not region_continues(bottom), bottom_cell(C).
:- cell(C, l), not region_continues(left), left_cell(C).
:- cell(C, l), not region_continues(right), right_cell(C).
:- cell(0, l), not region_upperleft.
:- cell(COLS-1, l), not region_upperright, cells(ROWS, COLS).
:- cell((ROWS-1)*COLS, l), not region_bottomleft, cells(ROWS, COLS).
:- cell(ROWS*COLS-1, l), not region_bottomright, cells(ROWS, COLS).

% Definitions of corners
region_upperleft :- region_continues(upper), region_continues(left).
region_upperright :- region_continues(upper), region_continues(right).
region_bottomleft :- region_continues(bottom), region_continues(left).
region_bottomright :- region_continues(bottom), region_continues(right).

% Definitions of cell that touches the border of the quadrant
upper_cell(C) :- cell_position(C), cells(ROWS, COLS), C < COLS, C \ COLS > 0, C \ COLS < COLS-1.
bottom_cell(C) :- cell_position(C), cells(ROWS, COLS), C >= (ROWS-1)*COLS, C \ COLS > 0, C \ COLS < COLS-1.
left_cell(C) :- cell_position(C), cells(ROWS, COLS), C \ COLS == 0, C >= COLS, C < (ROWS-1)*COLS.
right_cell(C) :- cell_position(C), cells(ROWS, COLS), C \ COLS == COLS - 1, C >= COLS, C < (ROWS-1) * COLS.
