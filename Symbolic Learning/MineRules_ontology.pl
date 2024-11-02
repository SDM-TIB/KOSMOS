% Load the ontology file
%:-['LC-ontology2.pl'].
:- ['lc-ontology-short.pl'] .
% Modified paths predicate with cycle detection and depth limit
paths(Y, Label, [Label,Label1], _, Visited) :- 
    edge(Y, Z, Label1), 
    Label1 \= Label,
    \+ member(Z-Label1, Visited).
paths(Y, Label, [Label|List1], MaxDepth, Visited) :- 
    MaxDepth > 0,
    edge(Y, Z, Label1),
    Label1 \= Label,
    \+ member(Z-Label1, Visited),
    NewMaxDepth is MaxDepth - 1,
    paths(Z, Label1, List1, NewMaxDepth, [Z-Label1|Visited]),
    \+ member(Label, List1).

% Modified entry point for finding paths with depth limit
enumeratingPaths(Label, Paths, MaxDepth) :-
    findall(Path, (edge(_, Y, Label), paths(Y, Label, Path, MaxDepth, [])), Paths).

% Modified utility predicate to find all paths with depth limit
find_all_paths(Label, AllPaths, MaxDepth) :- 
    enumeratingPaths(Label, Paths, MaxDepth), 
    findall(Path, member(Path, Paths), AllPaths).

% Modified allPaths predicate with depth limit
allPaths([Label], Paths, MaxDepth) :- find_all_paths(Label, Paths, MaxDepth), !.  
allPaths([Label|ListHeads], Paths, MaxDepth) :- 
    allPaths([Label], Paths1, MaxDepth),
    allPaths(ListHeads, Paths2, MaxDepth),
    append(Paths1, Paths2, Paths).
allPaths([], [], _).

% Transform a single path to a rule
path_to_rule(Path, Rule) :-
    Path = [Head|Body],
    (Body = [] -> 
        Rule = (Head :- true)
    ;
        list_to_conjunction(Body, BodyTerm),
        Rule = (Head :- BodyTerm)
    ).

% Helper predicate to convert a list to a conjunction
list_to_conjunction([X], X).
list_to_conjunction([X|Xs], (X, Rest)) :-
    list_to_conjunction(Xs, Rest).

% Transform all paths to rules and remove duplicates
transform_paths_to_rules(Paths, UniqueRules) :-
    maplist(path_to_rule, Paths, Rules),
    remove_duplicate_rules(Rules, UniqueRules).

% Remove duplicate rules using term comparison
remove_duplicate_rules(Rules, UniqueRules) :-
    sort(Rules, SortedRules),
    remove_equivalent_rules(SortedRules, UniqueRules).

% Remove rules that are equivalent even if written differently
remove_equivalent_rules([], []).
remove_equivalent_rules([Rule|Rest], UniqueRules) :-
    Rule = (Head :- Body),
    partition(equivalent_to_rule(Head, Body), Rest, Equivalent, NotEquivalent),
    remove_equivalent_rules(NotEquivalent, RestUnique),
    UniqueRules = [Rule|RestUnique].

% Check if two rules are equivalent
equivalent_to_rule(Head1, Body1, (Head2 :- Body2)) :-
    Head1 = Head2,
    equivalent_bodies(Body1, Body2).

% Check if two rule bodies are equivalent
equivalent_bodies(true, true) :- !.
equivalent_bodies(Body1, Body2) :-
    term_to_list(Body1, List1),
    term_to_list(Body2, List2),
    msort(List1, Sorted1),
    msort(List2, Sorted2),
    Sorted1 = Sorted2.

% Convert a conjunction term to a list
term_to_list(Term, List) :-
    (Term = (A, B) ->
        term_to_list(A, List1),
        term_to_list(B, List2),
        append(List1, List2, List)
    ; Term = true ->
        List = []
    ;
        List = [Term]
    ).

% Add variables to a rule based on ontology relationships
add_variables_to_rule((Head :- Body), (HeadWithVars :- BodyWithVars)) :-
    % Initialize variable counter and variable map
    b_setval(var_counter, 1),
    empty_assoc(VarMap),
    
    % Process head predicate
    Head =.. [HeadPred],
    add_pred_variables(HeadPred, VarMap, NewVarMap, HeadWithVars),
    
    % Process body predicates
    (Body = true ->
        BodyWithVars = true
    ;
        add_body_variables(Body, NewVarMap, BodyWithVars)
    ).

% Add variables to a single predicate
add_pred_variables(Pred, VarMap, NewVarMap, PredWithVars) :-
    % Get Patient variable (always X1 for consistency)
    get_or_create_var('Patient', VarMap, PatientVar, VarMap1),
    
    % Get or create variable for the second argument
    get_or_create_var(Pred, VarMap1, EntityVar, NewVarMap),
    
    % Construct predicate with variables
    PredWithVars =.. [Pred, PatientVar, EntityVar].

% Add variables to body predicates
add_body_variables((A, B), VarMap, (AWithVars, BWithVars)) :- !,
    add_body_variables(A, VarMap, AWithVars),
    add_body_variables(B, VarMap, BWithVars).
add_body_variables(Pred, VarMap, PredWithVars) :-
    add_pred_variables(Pred, VarMap, _, PredWithVars).

% Get existing variable or create new one
get_or_create_var(Key, VarMap, Var, NewVarMap) :-
    (get_assoc(Key, VarMap, Var) ->
        NewVarMap = VarMap
    ;
        b_getval(var_counter, Counter),
        atom_concat('X', Counter, Var),
        NewCounter is Counter + 1,
        b_setval(var_counter, NewCounter),
        put_assoc(Key, VarMap, Var, NewVarMap)
    ).

% Transform all rules to include variables
transform_rules_with_variables([], []).
transform_rules_with_variables([Rule|Rest], [TransformedRule|TransformedRest]) :-
    add_variables_to_rule(Rule, TransformedRule),
    transform_rules_with_variables(Rest, TransformedRest).

% Write a single rule to a file
write_rule_to_file(Stream, (Head :- Body)) :-
    writeq(Stream, Head),
    write(Stream, ' :- '),
    writeq(Stream, Body),
    write(Stream, '.'),
    nl(Stream).

% Write all rules to a file with error handling and diagnostics
write_rules_to_file(Filename, Rules) :-
    catch(
        (   open(Filename, write, Stream),
            maplist(write_rule_to_file(Stream), Rules),
            close(Stream),
            format('Rules successfully written to ~w~n', [Filename])
        ),
        Error,
        (   format('Error writing to file: ~w~n', [Error]),
            print_file_diagnostics(Filename),
            fail
        )
    ).

% Print diagnostic information about the file and directory
print_file_diagnostics(Filename) :-
    format('Attempting to write to: ~w~n', [Filename]),
    file_directory_name(Filename, Dir),
    format('Directory: ~w~n', [Dir]),
    (exists_directory(Dir) ->
        format('Directory exists.~n')
    ;
        format('Directory does not exist.~n')
    ),
    (access_file(Dir, write) ->
        format('You have write permission in this directory.~n')
    ;
        format('You do not have write permission in this directory.~n')
    ).

% Main predicate to get paths and write rules with variables
get_paths_and_write_rules_with_vars(Labels, Paths, UniqueRules, MaxDepth, OutputPath) :-
    allPaths(Labels, Paths, MaxDepth),
    transform_paths_to_rules(Paths, Rules),
    remove_duplicate_rules(Rules, UniqueRules),
    transform_rules_with_variables(UniqueRules, RulesWithVars),
    write_rules_to_file(OutputPath, RulesWithVars).
