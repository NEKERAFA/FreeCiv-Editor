%players(2).
%distance(3).

% Defines the contain of the cells
cells(l; w; m).

nation(portuguese;ukrainian;romanian;danish;finnish;austrian;italian;french).
nation(spanish;swedish;croatian;dutch;hungarian;belgian).
nation(serbian;czech;russian;irish;turkish;greek;arab;swiss;slovenian).
nation(icelandic;scottish;latvian;slovakian;estonian;bavarian;english).
nation(carthaginian;israeli;lithuanian;bulgarian;polish;german).

% Manhattan distance
manhattan(P1, P2, |X1-X2|+|Y1-Y2|) :- cell(P1, T1), cells(T1), cell(P2, T2), cells(T2), p(X1,Y1)=P1, p(X2,Y2)=P2, P1 != P2.

% Generates a player
N { player(P) : cell(P, l) } N :- players(N).

% Gets the distance to the water
greater_dist_water(J, N) :- player(J), cell(P1, w), cell(P2, w), manhattan(J, P1, N), manhattan(J, P2, M), N>M.
water_distance(J, D) :- player(J), cell(P, w), manhattan(J, P, D), not greater_dist_water(J, D).

% Gets tje distance to thee mountains
greater_dist_mountain(J, N) :- player(J), cell(P1, m), cell(P2, m), manhattan(J, P1, N), manhattan(J, P2, M), N>M.
mountain_distance(J, D) :- player(J), cell(P, m), manhattan(J, P, D), not greater_dist_mountain(J, D).

% Forbidden that a player is near N distance than other player
:- distance(N), manhattan(P1, P2, M), player(P1), player(P2), N > M.

% Maximize the distance to the mountains and minimize the distance to the water
#minimize{D : player(J), water_distance(J,D)}.
#maximize{D : player(J), mountain_distance(J,D)}.

1 { startpos(P, N) : nation(N) } 1 :- player(P).
