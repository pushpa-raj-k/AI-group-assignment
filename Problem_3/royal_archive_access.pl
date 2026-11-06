:- op(300, fy, ~).      % negation
:- op(500, xfy, &).     % conjunction
:- op(600, xfy, or).    % disjunction
:- op(700, xfy, =>).    % implication

:- dynamic cl/4, counter/1, derived_list/1.

%% ----------------------------------------------------------------------
%%   Constants  : mira, scroll_7, royal_archive (implicit in stored_in_archive)
%%   Variables  : x (person), r (record)
%%   Predicates : archivist(x)        x is an archivist
%%                verifies(x,r)       x verifies record r
%%                trusted(x)          x is trusted
%%                access(x,r)         x has access to r
%%                sealed(r)           r is sealed
%%                permitted(x,r)      x is permitted to inspect r
%%                inspects(x,r)       x inspects r
%%                finds_mark(x,r)     x finds a hidden mark in r
%%                stored_in_archive(r) r is stored in the royal archive
%% ----------------------------------------------------------------------

%% ======================================================================
%% Step 1: Predicate logic representation
%% ======================================================================
stage(1, 'Rule 1', all(x, all(r, (archivist(x) & verifies(x,r)) => trusted(x)))).
stage(1, 'Rule 2', all(x, all(r, (trusted(x) & access(x,r) & sealed(r)) => permitted(x,r)))).
stage(1, 'Rule 3', all(x, all(r, (inspects(x,r) & finds_mark(x,r)) => verifies(x,r)))).
stage(1, 'Rule 4', all(r, stored_in_archive(r) => sealed(r))).
stage(1, 'Fact 5', stored_in_archive(scroll_7)).
stage(1, 'Fact 6', access(mira, scroll_7)).
stage(1, 'Fact 7', inspects(mira, scroll_7) & finds_mark(mira, scroll_7)).
stage(1, 'Fact 8', archivist(mira)).
stage(1, 'Goal  ', trusted(mira)).

%% ======================================================================
%% Step 2: Negation of goal
%% ======================================================================
stage(2, 'Negated goal', ~trusted(mira)).

%% ======================================================================
%% Step 3: Implication removal   (A => B  ==>  ~A or B)
%% ======================================================================
stage(3, 'Rule 1', all(x, all(r, ~(archivist(x) & verifies(x,r)) or trusted(x)))).
stage(3, 'Rule 2', all(x, all(r, ~(trusted(x) & access(x,r) & sealed(r)) or permitted(x,r)))).
stage(3, 'Rule 3', all(x, all(r, ~(inspects(x,r) & finds_mark(x,r)) or verifies(x,r)))).
stage(3, 'Rule 4', all(r, ~stored_in_archive(r) or sealed(r))).
stage(3, 'Facts 5-8 and negated goal', 'unchanged (no implications)').

%% ======================================================================
%% Step 4: Negation movement   (De Morgan: ~(A & B) ==> ~A or ~B)
%% ======================================================================
stage(4, 'Rule 1', all(x, all(r, ~archivist(x) or ~verifies(x,r) or trusted(x)))).
stage(4, 'Rule 2', all(x, all(r, ~trusted(x) or ~access(x,r) or ~sealed(r) or permitted(x,r)))).
stage(4, 'Rule 3', all(x, all(r, ~inspects(x,r) or ~finds_mark(x,r) or verifies(x,r)))).
stage(4, 'Rule 4', all(r, ~stored_in_archive(r) or sealed(r))).
stage(4, 'Facts 5-8 and negated goal', 'unchanged (negations already on atoms)').

%% ======================================================================
%% Step 5: Standardization (each quantifier gets its own variable name)
%% ======================================================================
stage(5, 'Rule 1', all(x1, all(r1, ~archivist(x1) or ~verifies(x1,r1) or trusted(x1)))).
stage(5, 'Rule 2', all(x2, all(r2, ~trusted(x2) or ~access(x2,r2) or ~sealed(r2) or permitted(x2,r2)))).
stage(5, 'Rule 3', all(x3, all(r3, ~inspects(x3,r3) or ~finds_mark(x3,r3) or verifies(x3,r3)))).
stage(5, 'Rule 4', all(r4, ~stored_in_archive(r4) or sealed(r4))).

%% ======================================================================
%% Step 6: Skolemization
%%   There is NO existential quantifier anywhere in the knowledge base, so
%%   no Skolem constants/functions are needed. Only the universal
%%   quantifiers are dropped (all remaining variables are universal).
%% ======================================================================
stage(6, 'Rule 1', ~archivist(x1) or ~verifies(x1,r1) or trusted(x1)).
stage(6, 'Rule 2', ~trusted(x2) or ~access(x2,r2) or ~sealed(r2) or permitted(x2,r2)).
stage(6, 'Rule 3', ~inspects(x3,r3) or ~finds_mark(x3,r3) or verifies(x3,r3)).
stage(6, 'Rule 4', ~stored_in_archive(r4) or sealed(r4)).
stage(6, 'Skolemization', 'not required: no existential quantifiers').

%% ======================================================================
%% Step 7: CNF clauses   kb(Id, Source, ListOfLiterals)
%%   A literal is pos(Atom) or neg(Atom); Prolog variables = FOL variables.
%%   Fact 7 is a conjunction, so it splits into two unit clauses (C7, C8).
%% ======================================================================
kb(1,  'Rule 1',        [neg(archivist(X)), neg(verifies(X,_R)), pos(trusted(X))]).
kb(2,  'Rule 2 (unused)',[neg(trusted(X)), neg(access(X,R)), neg(sealed(R)), pos(permitted(X,R))]).
kb(3,  'Rule 3',        [neg(inspects(X,R)), neg(finds_mark(X,R)), pos(verifies(X,R))]).
kb(4,  'Rule 4',        [neg(stored_in_archive(R)), pos(sealed(R))]).
kb(5,  'Fact 5',        [pos(stored_in_archive(scroll_7))]).
kb(6,  'Fact 6',        [pos(access(mira, scroll_7))]).
kb(7,  'Fact 7a',       [pos(inspects(mira, scroll_7))]).
kb(8,  'Fact 7b',       [pos(finds_mark(mira, scroll_7))]).
kb(9,  'Fact 8',        [pos(archivist(mira))]).
kb(10, 'Negated goal',  [neg(trusted(mira))]).

%% ======================================================================
%% Step 8: Resolution implementation and execution
%%   Set-of-support resolution (breadth first). Starting from the negated
%%   goal, the given clause is resolved against every clause in the
%%   database until the empty clause [] appears.
%% ======================================================================

comp(pos(P), neg(P), P).
comp(neg(P), pos(P), P).

resolve(L1, L2, Res, P) :-
    copy_term(L1, A),
    copy_term(L2, B),
    select(X, A, RA),
    select(Y, B, RB),
    comp(X, Y, P),
    append(RA, RB, R0),
    dedupe(R0, Res).

dedupe([], []).
dedupe([H|T], R) :-
    (   memberchk_eq(H, T) -> dedupe(T, R)
    ;   R = [H|R1], dedupe(T, R1)
    ).
memberchk_eq(X, [Y|T]) :- ( X == Y -> true ; memberchk_eq(X, T) ).

tautology(L) :- member(pos(P), L), member(neg(Q), L), P == Q, !.

new_id(N) :- retract(counter(N0)), N is N0 + 1, assertz(counter(N)).

load_clauses :-
    retractall(cl(_,_,_,_)), retractall(counter(_)),
    forall(kb(Id, _, L), assertz(cl(Id, L, given, none))),
    assertz(counter(10)).

search([G|Rest], Found) :-
    cl(G, GL, _, _),
    findall(Id2-Res-P,
            ( cl(Id2, OL, _, _), Id2 \== G, resolve(GL, OL, Res, P) ),
            Rs),
    add_results(Rs, G, [], New, Found0),
    (   nonvar(Found0) -> Found = Found0
    ;   append(Rest, New, Queue), search(Queue, Found)
    ).

add_results([], _, N, N, _).
add_results([Id2-Res-P|T], G, N0, N, Found) :-
    (   nonvar(Found) -> N = N0
    ;   Res == []
    ->  new_id(Id), assertz(cl(Id, [], [G,Id2], P)), Found = Id, N = N0
    ;   tautology(Res)
    ->  add_results(T, G, N0, N, Found)
    ;   cl(_, Old, _, _), Old =@= Res
    ->  add_results(T, G, N0, N, Found)
    ;   new_id(Id), assertz(cl(Id, Res, [G,Id2], P)),
        append(N0, [Id], N1),
        add_results(T, G, N1, N, Found)
    ).


ancestors(Id, Acc, Acc)  :- memberchk(Id, Acc), !.
ancestors(Id, Acc0, Acc) :-
    cl(Id, _, Ps, _),
    (   Ps == given -> Acc = [Id|Acc0]
    ;   foldl(ancestors, Ps, [Id|Acc0], Acc)
    ).

label(Id, L) :- Id =< 10, !, format(atom(L), 'C~d', [Id]).
label(Id, L) :- Id > 10, derived_list(D), nth1(I, D, Id), !, format(atom(L), 'R~d', [I]).

pp_lit(pos(P)) :- write_term(P, [numbervars(true), spacing(next_argument)]).
pp_lit(neg(P)) :- write('~'), write_term(P, [numbervars(true), spacing(next_argument)]).
pp_lits([]) :- write('[]  (EMPTY CLAUSE)').
pp_lits([L]) :- !, pp_lit(L).
pp_lits([L|T]) :- pp_lit(L), write(' | '), pp_lits(T).
pp_clause(Lits) :- copy_term(Lits, C), numbervars(C, 0, _), pp_lits(C).

print_proof(EmptyId) :-
    ancestors(EmptyId, [], All),
    include(<(10), All, D0), sort(D0, Derived),
    retractall(derived_list(_)), assertz(derived_list(Derived)),
    forall(nth1(I, Derived, Id),
           ( cl(Id, Lits, [P1,P2], On),
             label(P1, L1), label(P2, L2),
             copy_term(On, OnC), numbervars(OnC, 0, _),
             format('R~d = Resolve(~w, ~w) on ', [I, L1, L2]),
             write_term(OnC, [numbervars(true), spacing(next_argument)]), nl,
             write('      R'), write(I), write(' : '), pp_clause(Lits), nl, nl )).

print_stage(N, Title) :-
    format('~n--- Step ~d: ~w ---~n', [N, Title]),
    forall(stage(N, Lbl, F),
           ( format('  ~w : ', [Lbl]),
             write_term(F, [spacing(next_argument)]), nl )).

main :-
    print_stage(1, 'Predicate logic representation'),
    print_stage(2, 'Negation of goal'),
    print_stage(3, 'Implication removal'),
    print_stage(4, 'Negation movement'),
    print_stage(5, 'Standardization'),
    print_stage(6, 'Skolemization'),
    format('~n--- Step 7: CNF clauses ---~n'),
    forall(kb(Id, Src, L),
           ( format('  C~d (~w) : ', [Id, Src]), pp_clause(L), nl )),
    format('~n--- Step 8: Resolution refutation ---~n~n'),
    load_clauses,
    (   search([10], Found)
    ->  print_proof(Found),
        format('Empty clause [] derived  =>  contradiction.~n'),
        format('Therefore trusted(mira) follows from the knowledge base. QED~n')
    ;   format('No refutation found: goal NOT proved.~n')
    ).