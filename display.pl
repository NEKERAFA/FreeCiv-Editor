:- ['solutions.pl'].

write_rows(N,M) :-
    N1 is N-1, between(0,N1,I), write_row(M,I),nl,fail; !.
write_row(M,I) :-
    M1 is M-1, between(0,M1,J), C is I*M+J, write_cell(C), fail; !.

write_cell(C):-
    rootcell(C,I),!,write(I)
    ; cell(C,X), !, text(L),member(X=V,L),write(V)
    ; write('X').

text([ocean=':', deepocean=';',land='l',grass='g',hills='h',desert='d',forest='f',plains='p']).
