:- dynamic answer/2,numanswers/1.

assert_answer(N) :-
    answer(N,S),
    assert_all(S).

assert_all([]):-!.
assert_all([F|Fs]):-assertz(F),assert_all(Fs),!.

clingo(Files) :- clingo(Files,1).
clingo(Files,N) :-
    (retractall(answer(_,_)),!;true),
    filenames(Files,Fnames),
    concat_atom(['clingo --verbose=0 ',N,' ',Fnames,' > answers.tmp'],Command),
    shell(Command,_),set_count(numanswers,0),
    see('answers.tmp'), read_answers, seen,
    delete_file('answers.tmp').

read_answers:-
    gettoken([0' ,10],T,D),!,
    (  T='UNSATISFIABLE',!
     ; T='SATISFIABLE',!
     ; atom_to_term(T,Term,_),
       (D=0' ,!,read_facts([Term],S); S=[Term]),
       numanswers(N),
       assertz(answer(N,S)),
       incr(numanswers,1),
       read_answers
    ).
read_answers.	

read_facts(S,S1) :-
	gettoken([0' ,10],T,D),!,
	atom_to_term(T,Term,_),
	(D=0' ,!,read_facts([Term|S],S1); S1=[Term|S]).  

gettoken(Delims,Tok,Delim):-
	gettokenchars(Delims,Chars,Delim),
	atom_codes(Tok,Chars).

gettokenchars(Delims,Cs,Delim):-
  get0(C),!,
  ( C = -1,!,fail
  ; member(C,Delims),!,Delim=C,Cs=[]  
  ; gettokenchars(Delims,Cs0,Delim), Cs=[C|Cs0]
  ).

% Updates a dynamic predicate Pred/1 whose argument is an integer I, by adding
% a quantity X to I.
incr(Pred,X):-
	T =.. [Pred,N],
	(call(T),!, retractall(T); N=0),
	M is N + X,
	T2 =.. [Pred,M],
	asserta(T2).

set_count(Pred,X):-
	T=..[Pred,_],
	(retractall(T),!; true),
	T2=..[Pred,X],asserta(T2).

filenames([],'') :- !.
filenames([F|Fs],Txt) :- !,filenames(Fs,T),concat_atom([F,' ',T],Txt).
filenames(F,F).
