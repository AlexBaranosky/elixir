% Grammar for the Elixir language done with yecc
% Copyright (C) 2011 Jose Valim

Nonterminals
  grammar expr_list
  expr block_expr curly_expr call_expr max_expr base_expr
  matched_expr matched_op_expr unmatched_expr unmatched_op_expr
  comma_separator kv_eol
  add_op mult_op unary_op addadd_op multmult_op
  match_op arrow_op module_ref_op default_op when_op pipe_op
  andand_op oror_op andalso_op orelse_op and_op or_op comp_expr_op
  open_paren close_paren
  open_bracket close_bracket
  open_curly close_curly
  comma_expr call_args_comma_expr call_args call_args_parens
  matched_comma_expr call_args_no_parens
  kv_comma base_orddict
  matched_kv_comma matched_base_orddict
  do_eol end_eol kv_item kv_list do_block curly_block
  dot_op dot_identifier dot_do_identifier dot_curly_identifier
  dot_paren_identifier dot_punctuated_identifier parens_call
  var list
  tuple long_tuple long_tuple_call_args
  .

Terminals
  'do' 'end'
  identifier kv_identifier punctuated_identifier paren_identifier
  do_identifier curly_identifier
  number signed_number atom module_ref bin_string list_string
  dot_call_op special_op comp_op
  'not' 'and' 'or' 'xor' 'andalso' 'orelse' 'when'
  '=' '+' '-' '*' '/' '++' '--' '**' '//' '<-'
  '(' ')' eol ',' '[' ']' '|' '{' '}' '.' '::' '^'
  '&&' '||' '!'
  .

Rootsymbol grammar.

Left      10 do.
Left      20 ','.  % Solve nested call_args conflicts
Right     30 default_op.
Right     40 when_op.
Left      50 pipe_op.
Right     60 match_op.
Right     70 arrow_op.
Left      80 oror_op.
Left      90 andand_op.
Left     100 orelse_op.
Left     110 andalso_op.
Left     120 or_op.
Left     130 and_op.
Left     150 comp_expr_op.
Left     160 add_op.
Left     170 mult_op.
Right    180 addadd_op.
Right    190 multmult_op.
Left     260 dot_call_op.
Left     260 dot_op.
Right    270 module_ref_op.
Nonassoc 280 unary_op.
Nonassoc 290 var.
Nonassoc 300 special_op.

%%% MAIN FLOW OF EXPRESSIONS

grammar -> expr_list : lists:reverse('$1').
grammar -> eol expr_list : lists:reverse('$2').
grammar -> expr_list eol : lists:reverse('$1').
grammar -> eol expr_list eol : lists:reverse('$2').
grammar -> '$empty' : [nil].

% Note expressions are on reverse order
expr_list -> expr : ['$1'].
expr_list -> expr_list eol expr : ['$3'|'$1'].

expr -> matched_expr : '$1'.
expr -> unmatched_expr : '$1'.

matched_expr   -> matched_op_expr   : '$1'.
unmatched_expr -> unmatched_op_expr : '$1'.

unmatched_op_expr -> matched_expr match_op unmatched_expr : build_op('$2', '$1', '$3').
unmatched_op_expr -> unary_op expr : build_unary_op('$1', '$2').
unmatched_op_expr -> special_op expr : build_special_op('$1', '$2').
unmatched_op_expr -> block_expr : '$1'.

matched_op_expr -> matched_expr match_op matched_expr : build_op('$2', '$1', '$3').
matched_op_expr -> matched_expr add_op matched_expr : build_op('$2', '$1', '$3').
matched_op_expr -> matched_expr mult_op matched_expr : build_op('$2', '$1', '$3').
matched_op_expr -> matched_expr addadd_op matched_expr : build_op('$2', '$1', '$3').
matched_op_expr -> matched_expr multmult_op matched_expr : build_op('$2', '$1', '$3').
matched_op_expr -> matched_expr andand_op matched_expr : build_op('$2', '$1', '$3').
matched_op_expr -> matched_expr oror_op matched_expr : build_op('$2', '$1', '$3').
matched_op_expr -> matched_expr andalso_op matched_expr : build_op('$2', '$1', '$3').
matched_op_expr -> matched_expr orelse_op matched_expr : build_op('$2', '$1', '$3').
matched_op_expr -> matched_expr and_op matched_expr : build_op('$2', '$1', '$3').
matched_op_expr -> matched_expr or_op matched_expr : build_op('$2', '$1', '$3').
matched_op_expr -> matched_expr pipe_op matched_expr : build_op('$2', '$1', '$3').
matched_op_expr -> matched_expr when_op matched_expr : build_op('$2', '$1', '$3').
matched_op_expr -> matched_expr arrow_op matched_expr : build_op('$2', '$1', '$3').
matched_op_expr -> matched_expr module_ref_op matched_expr : build_op('$2', '$1', '$3').
matched_op_expr -> matched_expr default_op matched_expr : build_op('$2', '$1', '$3').
matched_op_expr -> matched_expr comp_expr_op matched_expr : build_expr_op('$2', '$1', '$3').
matched_op_expr -> unary_op matched_expr : build_unary_op('$1', '$2').
matched_op_expr -> special_op matched_expr : build_special_op('$1', '$2').
matched_op_expr -> curly_expr : '$1'.

block_expr -> parens_call call_args_parens do_block : build_identifier('$1', '$2', '$3').
block_expr -> dot_punctuated_identifier call_args_no_parens do_block : build_identifier('$1', '$2', '$3').
block_expr -> dot_curly_identifier long_tuple_call_args do_block : build_identifier('$1', '$2', '$3').
block_expr -> dot_do_identifier do_block : build_identifier('$1', [], '$2').
block_expr -> dot_identifier call_args_no_parens do_block : build_identifier('$1', '$2', '$3').

curly_expr -> parens_call call_args_parens curly_block : build_identifier('$1', '$2', '$3').
curly_expr -> dot_curly_identifier curly_block : build_identifier('$1', [], '$2').
curly_expr -> call_expr : '$1'.

call_expr -> parens_call call_args_parens : build_identifier('$1', '$2').
call_expr -> dot_curly_identifier long_tuple_call_args : build_identifier('$1', '$2').
call_expr -> dot_punctuated_identifier call_args_no_parens : build_identifier('$1', '$2').
call_expr -> dot_identifier call_args_no_parens : build_identifier('$1', '$2').
call_expr -> dot_punctuated_identifier : build_identifier('$1', []).
call_expr -> dot_do_identifier : build_identifier('$1', false).
call_expr -> max_expr : '$1'.

max_expr -> base_expr : '$1'.
max_expr -> open_paren ')' : build_block([]).
max_expr -> open_paren expr_list close_paren : build_block('$2').

base_expr -> number : ?exprs('$1').
base_expr -> signed_number : { element(4, '$1'), ?line('$1'), ?exprs('$1') }.
base_expr -> atom : build_atom('$1').
base_expr -> var : build_identifier('$1', false).
base_expr -> list : '$1'.
base_expr -> tuple : '$1'.
base_expr -> module_ref : '$1'.
base_expr -> bin_string  : build_bin_string('$1').
base_expr -> list_string : build_list_string('$1').

%% Helpers

var -> dot_identifier : '$1'.

comma_separator -> ','     : '$1'.
comma_separator -> ',' eol : '$1'.

open_paren -> '('      : '$1'.
open_paren -> '(' eol  : '$1'.
close_paren -> ')'     : '$1'.
close_paren -> eol ')' : '$2'.

open_bracket  -> '['     : '$1'.
open_bracket  -> '[' eol : '$1'.
close_bracket -> ']'     : '$1'.
close_bracket -> eol ']' : '$2'.

open_curly  -> '{'     : '$1'.
open_curly  -> '{' eol : '$1'.
close_curly -> '}'     : '$1'.
close_curly -> eol '}' : '$2'.

% Operators

add_op -> '+' : '$1'.
add_op -> '-' : '$1'.
add_op -> '+' eol : '$1'.
add_op -> '-' eol : '$1'.

mult_op -> '*' : '$1'.
mult_op -> '/' : '$1'.
mult_op -> '*' eol : '$1'.
mult_op -> '/' eol : '$1'.

addadd_op -> '++' : '$1'.
addadd_op -> '--' : '$1'.
addadd_op -> '++' eol : '$1'.
addadd_op -> '--' eol : '$1'.

multmult_op -> '**' : '$1'.
multmult_op -> '**' eol : '$1'.

default_op -> '//' : '$1'.
default_op -> '//' eol : '$1'.

unary_op -> '+' : '$1'.
unary_op -> '+' eol : '$1'.
unary_op -> '-' : '$1'.
unary_op -> '-' eol : '$1'.
unary_op -> '!' : '$1'.
unary_op -> '!' eol : '$1'.
unary_op -> '^' : '$1'.
unary_op -> '^' eol : '$1'.
unary_op -> 'not' : '$1'.
unary_op -> 'not' eol : '$1'.
unary_op -> '::' : '$1'.
unary_op -> '::' eol : '$1'.

match_op -> '=' : '$1'.
match_op -> '=' eol : '$1'.

andand_op -> '&&' : '$1'.
andand_op -> '&&' eol : '$1'.

oror_op -> '||' : '$1'.
oror_op -> '||' eol : '$1'.

andalso_op -> 'andalso' : '$1'.
andalso_op -> 'andalso' eol : '$1'.

orelse_op -> 'orelse' : '$1'.
orelse_op -> 'orelse' eol : '$1'.

and_op -> 'and' : '$1'.
and_op -> 'and' eol : '$1'.

or_op -> 'or' : '$1'.
or_op -> 'or' eol : '$1'.
or_op -> 'xor' : '$1'.
or_op -> 'xor' eol : '$1'.

pipe_op -> '|' : '$1'.
pipe_op -> '|' eol : '$1'.

when_op -> 'when' : '$1'.
when_op -> 'when' eol : '$1'.

arrow_op -> '<-' : '$1'.
arrow_op -> '<-' eol : '$1'.

comp_expr_op -> comp_op : '$1'.
comp_expr_op -> comp_op eol : '$1'.

% Ref operator

module_ref_op -> '::' : '$1'.
module_ref_op -> '::' eol : '$1'.

% Dot operator

dot_op -> '.' : '$1'.
dot_op -> '.' eol : '$1'.

dot_identifier -> identifier : '$1'.
dot_identifier -> matched_expr dot_op identifier : { '.', ?line('$2'), ['$1', '$3'] }.

dot_do_identifier -> do_identifier : '$1'.
dot_do_identifier -> matched_expr dot_op do_identifier : { '.', ?line('$2'), ['$1', '$3'] }.

dot_curly_identifier -> curly_identifier : '$1'.
dot_curly_identifier -> matched_expr dot_op curly_identifier : { '.', ?line('$2'), ['$1', '$3'] }.

dot_paren_identifier -> paren_identifier : '$1'.
dot_paren_identifier -> matched_expr dot_op paren_identifier : { '.', ?line('$2'), ['$1', '$3'] }.

dot_punctuated_identifier -> punctuated_identifier : '$1'.
dot_punctuated_identifier -> matched_expr dot_op punctuated_identifier : { '.', ?line('$2'), ['$1', '$3'] }.

parens_call -> dot_paren_identifier : '$1'.
parens_call -> matched_expr dot_call_op : { '.', ?line('$2'), ['$1'] }. % Fun/local calls

% Function calls

matched_comma_expr -> matched_expr : ['$1'].
matched_comma_expr -> matched_comma_expr comma_separator matched_expr : ['$3'|'$1'].

call_args_no_parens -> matched_comma_expr : lists:reverse('$1').
call_args_no_parens -> matched_base_orddict : ['$1'].
call_args_no_parens -> matched_comma_expr comma_separator matched_base_orddict : lists:reverse(['$3'|'$1']).

comma_expr -> expr : ['$1'].
comma_expr -> comma_expr comma_separator expr : ['$3'|'$1'].

call_args_comma_expr -> comma_expr : lists:reverse('$1').
call_args_comma_expr -> base_orddict : ['$1'].
call_args_comma_expr -> comma_expr comma_separator base_orddict : lists:reverse(['$3'|'$1']).

call_args_parens -> open_paren ')' : [].
call_args_parens -> open_paren call_args_comma_expr close_paren : '$2'.

call_args -> call_args_comma_expr : build_args('$1').

% KV and orddict

kv_eol -> kv_identifier : '$1'.
kv_eol -> kv_identifier eol : '$1'.

kv_comma -> kv_eol expr : [{?exprs('$1'),'$2'}].
kv_comma -> kv_eol expr comma_separator kv_comma : orddict:update(?exprs('$1'), fun(X) -> X end, '$2', '$4').

matched_kv_comma -> kv_eol matched_expr : [{?exprs('$1'),'$2'}].
matched_kv_comma -> kv_eol matched_expr comma_separator kv_comma : orddict:update(?exprs('$1'), fun(X) -> X end, '$2', '$4').

base_orddict -> kv_comma : { '[:]', ?line(hd('$1')), '$1' }.
matched_base_orddict -> matched_kv_comma : { '[:]', ?line(hd('$1')), '$1' }.

% KV blocks

do_eol -> 'do' : '$1'.
do_eol -> 'do' eol : '$1'.

end_eol -> 'end' : '$1'.
end_eol -> eol 'end' : '$2'.

kv_item -> kv_identifier comma_expr eol : { ?exprs('$1'), { kv_block, ?line('$1'), [{lists:reverse('$2'),nil}] } }.
kv_item -> kv_identifier eol expr_list eol : { ?exprs('$1'), build_block('$3') }.
kv_item -> kv_identifier comma_expr eol expr_list eol : { ?exprs('$1'), { kv_block, ?line('$1'), [{lists:reverse('$2'),build_block('$4')}] } }.

kv_list -> kv_item : ['$1'].
kv_list -> kv_item kv_list : ['$1'|'$2'].

do_block -> do_eol 'end'                       : build_kv_block('$1', [], []).
do_block -> do eol kv_list 'end'               : build_kv_block('$1', [], '$3').
do_block -> do_eol expr_list end_eol           : build_kv_block('$1', '$2', []).
do_block -> do_eol expr_list eol kv_list 'end' : build_kv_block('$1', '$2', '$4').

curly_block -> open_curly '}'                       : build_kv_block('$1', [], []).
curly_block -> '{' eol kv_list '}'                  : build_kv_block('$1', [], '$3').
curly_block -> open_curly expr_list close_curly     : build_kv_block('$1', '$2', []).
curly_block -> open_curly expr_list eol kv_list '}' : build_kv_block('$1', '$2', '$4').

% Lists

list -> open_bracket ']' : [].
list -> open_bracket kv_comma close_bracket : sort_kv('$2').
list -> open_bracket expr close_bracket : ['$2'].
list -> open_bracket expr comma_separator call_args close_bracket : ['$2'|'$4'].

% Tuple
% We need to break call_args apart here to solve
% ambiguity between p { }, p { 1 } and p { 1, ... }

tuple -> open_curly '}' : { '{}', ?line('$1'), [] }.
tuple -> open_curly expr close_curly :  { '{}', ?line('$1'), build_args(['$2']) }.
tuple -> open_curly base_orddict close_curly :  { '{}', ?line('$1'), build_args(['$2']) }.
tuple -> long_tuple : '$1'.

long_tuple -> open_curly expr comma_separator call_args close_curly :  { '{}', ?line('$1'), ['$2'|'$4'] }.

long_tuple_call_args -> long_tuple : ['$1'].
long_tuple_call_args -> long_tuple comma_separator call_args_no_parens : ['$1'|'$3'].

Erlang code.

-define(op(Node), element(1, Node)).
-define(line(Node), element(2, Node)).
-define(exprs(Node), element(3, Node)).

% The following directive is needed for (significantly) faster compilation
% of the generated .erl file by the HiPE compiler. Please do not remove.
-compile([{hipe,[{regalloc,linear_scan}]}]).

%% Operators

build_op(Op, Left, Right) ->
  { ?op(Op), ?line(Op), [Left, Right] }.

build_expr_op(Op, Left, Right) ->
  { ?exprs(Op), ?line(Op), [Left, Right] }.

build_unary_op(Op, Expr) ->
  { ?op(Op), ?line(Op), [Expr] }.

build_special_op(Op, Expr) ->
  { ?exprs(Op), ?line(Op), [Expr] }.

%% Blocks

% Handle args that expects blocks of code
build_block([])                            -> nil;
build_block([nil])                         -> { block, 0, [nil] };
build_block([Expr]) when not is_list(Expr) -> Expr;
build_block(Exprs)                         -> { block, 0, lists:reverse(Exprs) }.

% Handle key value blocks
build_kv_block(Delimiter, Contents, IncompleteList) ->
  Line  = ?line(Delimiter),
  List  = [{do,build_block(Contents)}|IncompleteList],
  Final = lists:reverse(elixir_kv_block:merge(Line, [], List)),
  {'[:]', Line, Final}.

%% Args
% Build args by transforming [:] into the final form []
% and properly sorting the items.

build_args(Args) -> lists:map(fun build_arg/1, Args).
build_arg({ '[:]', _Line, Args }) -> sort_kv(Args);
build_arg(Else) -> Else.

%% Identifiers
% Those helpers are responsible to:
%
%   + Merge kv args and kv blocks arguments
%   + Handle dot operators and transform them in the proper function call
build_identifier(Expr, [], Block) ->
  build_identifier(Expr, [Block]);

build_identifier(Expr, Args, Block) ->
  { Reverse, Last } = last(Args, []),
  Final = case is_kv(Last) of
    true  ->
      { '[:]', Line, Left } = Last,
      { '[:]', _, Right }  = Block,
      KV = { '[:]', Line, elixir_kv_block:merge(Line, Left, Right) },
      lists:reverse([KV|Reverse]);
    false ->
      lists:reverse([Block,Last|Reverse])
  end,
  build_identifier(Expr, Final).

build_identifier({ '.', DotLine, [Expr, { Kind, _, Identifier }] }, Args) when
  Kind == identifier; Kind == punctuated_identifier;
  Kind == paren_identifier; Kind == do_identifier; Kind == curly_identifier ->
  build_identifier({ '.', DotLine, [Expr, Identifier] }, Args);

build_identifier({ '.', Line, _ } = Dot, Args) ->
  FArgs = case Args of
    false -> [];
    _ -> Args
  end,
  { Dot, Line, build_args(FArgs) };

build_identifier({ _, Line, Identifier }, false) ->
  { Identifier, Line, false };

build_identifier({ _, Line, Identifier }, Args) ->
  { Identifier, Line, build_args(Args) }.

%% Interpolation aware

build_bin_string({ bin_string, _Line, [H] }) when is_list(H) -> list_to_binary(H);
build_bin_string({ bin_string, Line, Args }) -> { bitstr, Line, Args }.

build_list_string({ list_string, _Line, [H] }) when is_list(H) -> H;
build_list_string({ list_string, Line, Args }) -> { binary_to_list, Line, [{ bitstr, Line, Args}] }.

build_atom({ atom, _Line, [H] }) when is_atom(H) -> H;
build_atom({ atom, _Line, [H] }) when is_list(H) -> list_to_atom(H);
build_atom({ atom, Line, Args }) -> { binary_to_atom, Line, [{ bitstr, Line, Args}, utf8] }.

%% Helpers

last([L], Acc)   -> { Acc, L };
last([H|T], Acc) -> last(T, [H|Acc]).

is_kv({'[:]', _, Args}) -> lists:all(fun is_kv_tuple/1, Args);
is_kv(_) -> false.

is_kv_tuple({ Key, _ }) when is_atom(Key) -> true;
is_kv_tuple(_) -> false.

sort_kv(List) -> lists:sort(fun sort_kv/2, List).
sort_kv({ A, _ }, { B, _ }) -> A =< B.