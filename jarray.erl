-module(jarray).
%% @author JerryPan<https://github.com/panii/jarray> ‎2013‎.‎3
%% @description My javascript arrays vs erlang lists serializing and deserializing util library.

%% usage(work with string): jarray:stringify(["AAA", "BBB", ["CCC", "DDD"]]). // result: "2#AAA||BBB||1#CCC|DDD"
%% usage(work with string): jarray:parse("2#AAA||BBB||1#CCC|DDD"). // result: ["AAA","BBB",["CCC","DDD"]]
%% usage(work with binary): jarray:stringify([<<"AAA">>, <<"BBB">>, [<<"CCC">>, <<"DDD">>]]). // result: <<"2#AAA||BBB||1#CCC|DDD">>
%% usage(work with binary): jarray:parse_binary(<<"2#AAA||BBB||1#CCC|DDD">>). // result: [<<"AAA">>,<<"BBB">>,[<<"CCC">>,<<"DDD">>]]

-export([stringify/1, parse/1, stringify_binary/1, parse_binary/1]).

-export([type_of/1, test_all/0, test_stringify_time/1, test_parse_time/1, test_stringify_binary_time/1, test_parse_binary_time/1, test_case/1, test_case_get_array/0, j_get_max_deep_work_with_string/3, j_get_max_deep_work_with_binary/3]).

-define(AT, "#").
-define(AT_BINARY, <<"#">>).
-define(Tokens, {"|","||","|||","||||","|||||","||||||","|||||||",
	"||||||||","|||||||||","||||||||||","|||||||||||","||||||||||||",
	"|||||||||||||","||||||||||||||","|||||||||||||||","||||||||||||||||",
	"|||||||||||||||||","||||||||||||||||||"}).
-define(Tokens_binary, {<<"|">>,<<"||">>,<<"|||">>,<<"||||">>,<<"|||||">>,<<"||||||">>,<<"|||||||">>,
	<<"||||||||">>,<<"|||||||||">>,<<"||||||||||">>,<<"|||||||||||">>,<<"||||||||||||">>,
	<<"|||||||||||||">>,<<"||||||||||||||">>,<<"|||||||||||||||">>,<<"||||||||||||||||">>,
	<<"|||||||||||||||||">>,<<"||||||||||||||||||">>}).

type_of(X) when is_list(X)      -> list;
type_of(X) when is_integer(X)   -> integer;
type_of(X) when is_binary(X)    -> binary;
type_of(X) when is_atom(X)      -> atom;
type_of(X) when is_boolean(X)   -> boolean;
type_of(X) when is_tuple(X)     -> tuple;

type_of(X) when is_float(X)     -> float;
type_of(X) when is_bitstring(X) -> bitstring;
type_of(X) when is_function(X)  -> function;
type_of(X) when is_pid(X)       -> pid;
type_of(X) when is_port(X)      -> port;
type_of(X) when is_reference(X) -> reference;
type_of(X) when is_pid(X)       -> pid;

type_of(_X)                     -> unknown.



% cd("/workspace/github/jarray").
% c(jarray).

% jarray:stringify([[1,2],[3,4]]).   // result   [49,35,1,2,124,3,4] and don't use raw number, use string instead
% jarray:stringify([["1","2"],["3","4"]]).   // result   "2#1#1|2||1#3|4"  
% jarray:stringify(["哈哈","呵呵"]).   // result   [49,35,21704,21704,124,21621,21621]
% jarray:stringify(["aa", ["bb","cc"]]).   // result   "2#aa||1#bb|cc"
% jarray:stringify(["aa", ["bb","cc",["d","ee"]]]).   // result   "3#aa|||2#bb||cc||1#d|ee"
% jarray:stringify(["aa", [["d","ee",["jerry"]],"bb","cc"], [["d","ee"],"bb","cc"]]).   // result   "4#aa||||3#2#d||ee||1#jerry|||bb|||cc||||3#2#d||ee|||bb|||cc"
% jarray:stringify(["aa",["CC","DD"],"bb"]).   // result   "2#aa||1#CC|DD||bb"
stringify(A) ->
	j_stringify_work_with_string(A, j_get_max_deep_work_with_string(A, 1, 1), 0).

% jarray:stringify_binary([<<"aa">>,[<<"CC">>,<<"DD">>],<<"bb">>]).   // result   <<"2#aa||1#CC|DD||bb">>
stringify_binary(A) ->
    j_stringify_work_with_binary(A, j_get_max_deep_work_with_binary(A, 1, 1), 0).

	% j_get_max_deep_work_with_string(A, 1, 1). % test max deep
j_get_max_deep_work_with_string([First|Remainder], CurrentDeep, MaxDeep) ->
	% io:format("j_get_max_deep_work_with_string: ~p,~p,~p,~p~n", [First, CurrentDeep, MaxDeep, Remainder]),
	if CurrentDeep > MaxDeep ->
			RealMaxDeep = CurrentDeep;
		true ->
			RealMaxDeep = MaxDeep
	end,
	La = type_of(First),
	% io:format("RealMaxDeep: ~p~n", [RealMaxDeep]),
	% io:format("La: ~p~n", [La]),
	case La of
		list -> j_get_max_deep_work_with_string(Remainder, CurrentDeep, j_get_max_deep_work_with_string(First, CurrentDeep + 1, RealMaxDeep));
		integer -> j_get_max_deep_work_with_string(Remainder, CurrentDeep, MaxDeep);
		_ -> MaxDeep
	end;
j_get_max_deep_work_with_string([] , _Deep, MaxDeep) ->
	MaxDeep;
j_get_max_deep_work_with_string(_ , _Deep, MaxDeep) ->
	MaxDeep.
    
% j_get_max_deep_work_with_binary(A, 1, 1). % test max deep
j_get_max_deep_work_with_binary([First|Remainder], CurrentDeep, MaxDeep) ->
	% io:format("j_get_max_deep_work_with_binary: ~p,~p,~p,~p~n", [First, CurrentDeep, MaxDeep, Remainder]),
	if CurrentDeep > MaxDeep ->
			RealMaxDeep = CurrentDeep;
		true ->
			RealMaxDeep = MaxDeep
	end,
	La = type_of(First),
	% io:format("RealMaxDeep: ~p~n", [RealMaxDeep]),
	% io:format("La: ~p~n", [La]),
	case La of
		list -> j_get_max_deep_work_with_binary(Remainder, CurrentDeep, j_get_max_deep_work_with_binary(First, CurrentDeep + 1, RealMaxDeep));
		_ -> j_get_max_deep_work_with_binary(Remainder, CurrentDeep, RealMaxDeep)
	end;
j_get_max_deep_work_with_binary([] , _Deep, MaxDeep) ->
	MaxDeep;
j_get_max_deep_work_with_binary(_ , _Deep, MaxDeep) ->
	MaxDeep.

j_stringify_work_with_string(A, MaxDeep, I) ->
	integer_to_list(MaxDeep - I)
	++
	?AT
	++
	string:join(
		lists:map(
			fun(X) ->
				j_stringify_work_with_string_foreach(X, MaxDeep, I + 1)
			end,
		A),
		j_getToken(MaxDeep - I)
	).

j_stringify_work_with_string_foreach([First|Remainder], _MaxDeep, _I) when is_integer(First) ->
	[First|Remainder];
j_stringify_work_with_string_foreach([First|Remainder], MaxDeep, I) when is_list(First) ->
	j_stringify_work_with_string([First|Remainder], MaxDeep, I);
j_stringify_work_with_string_foreach([First|_Remainder], _MaxDeep, _I) ->
	anything_to_list(First);
j_stringify_work_with_string_foreach(Term, _MaxDeep, _I) ->
	anything_to_list(Term).


%% [<<"aa">>, [[<<"d">>, <<"ee">>, [<<"jerry">>]], <<"bb">>, <<"cc">>], [[<<"d">>, <<"ee">>], <<"bb">>, <<"cc">>]]
j_stringify_work_with_binary(A, MaxDeep, I) ->
    erlang:iolist_to_binary([integer_to_binary(MaxDeep - I), ?AT_BINARY, 
        binary_join(
            j_getToken_binary(MaxDeep - I), 
            lists:map(
                fun(X) ->
                    j_stringify_work_with_binary_foreach(X, MaxDeep, I + 1)
                end,
            A)
        )]
    ).

j_stringify_work_with_binary_foreach(Term, MaxDeep, I) when is_list(Term) ->
	j_stringify_work_with_binary(Term, MaxDeep, I);
j_stringify_work_with_binary_foreach(Term, _MaxDeep, _I) ->
	anything_to_binary(Term).

% https://gist.github.com/FNickRU/4daf8fb9afe5caaee7ebd35f398a8ac9
binary_join(_Separator, []) ->
    <<>>;
binary_join(Separator, [H|T]) ->
    lists:foldl(fun (Value, Acc) -> <<Acc/binary, Separator/binary, Value/binary>> end, H, T).

% more slower
% j_stringify_work_with_binary2(A, MaxDeep, I) ->
    % erlang:iolist_to_binary([integer_to_binary(MaxDeep - I), ?AT_BINARY, 
        % binary_rtrim(j_getToken_binary(MaxDeep - I), erlang:iolist_to_binary(
            % lists:map(
                % fun(X) ->
                    % j_stringify_work_with_binary_foreach2(X, j_getToken_binary(MaxDeep - I), MaxDeep, I + 1)
                % end,
            % A)
        % ))]
    % ).
% j_stringify_work_with_binary_foreach2(Term, Separator, MaxDeep, I) when is_list(Term) ->
	% erlang:iolist_to_binary([j_stringify_work_with_binary2(Term, MaxDeep, I), Separator]);
% j_stringify_work_with_binary_foreach2(Term, Separator, _MaxDeep, _I) ->
    % Term2 = anything_to_binary(Term),
	% <<Term2/binary, Separator/binary>>.
% binary_rtrim(Separator, Binary) ->
    % TrimLen = byte_size(Separator),
    % TotalLen = byte_size(Binary),
    % NeedLen = TotalLen - TrimLen,
    % <<Need:NeedLen/binary, _Separator/binary>> = Binary,
    % Need.

j_getToken(L) ->
	element(L, ?Tokens).

j_getToken_binary(L) ->
	element(L, ?Tokens_binary).

% jarray:parse_binary(<<"2#haha||1#xi|xi||hehe">>).   // result   [<<"haha">>,[<<"xi">>,<<"xi">>],<<"hehe">>]
% jarray:parse_binary(<<"2#abc||1#de|fg">>).   // result   [<<"abc">>,[<<"de">>,<<"fg">>]]
% jarray:parse_binary(<<"2#abc||1#de|123">>).   // result   [<<"abc">>,[<<"de">>,<<"123">>]]
% parse_binary 比 parse 要快 50%
parse_binary(Str) ->
	case binary:split(Str, ?AT_BINARY) of
		[Str] -> Str;
		[I1, SubStr] ->
			I = binary_to_integer(I1),
			A = binary:split(SubStr, j_getToken_binary(I), [global]),
			lists:map(fun parse_binary/1, A)
	end.

% jarray:parse("2#haha||1#xi|xi||hehe").   // result   ["haha",["xi","xi"],"hehe"]
% jarray:parse("2#abc||1#de|fg").   // result   ["abc",["de","fg"]]
% jarray:parse("2#abc||1#de|123").   // result   ["abc",["de","123"]]
parse(Str) ->
	Pos = string:str(Str, ?AT),
	if  Pos > 0 ->
			I = list_to_integer(string:sub_string(Str, 1, Pos-1)),
			SubStr = string:substr(Str, Pos+1),
			A = explode(SubStr, j_getToken(I)),
			% A,
			lists:map(fun parse/1, A);
		true -> Str
	end.

explode(Instr, Token) ->
	explode(Instr, Token, []).

explode(Instr, Token, Result) ->
	Tpos = string:rstr(Instr,Token),
	if Tpos =:= 0 ->
			[Instr | Result];
		true ->
			NewResult = [string:substr(Instr,Tpos+string:len(Token)) | Result],
			explode(string:substr(Instr,1,Tpos-1),Token,NewResult)
	end.



% jarray:test_all(). 测试 test test_all()
test_all() ->
    put(benchmark, false),
    io:format("[Work with string] ~n"),
    io:format("Test test_get_max_deep() ~n"),
    jarray:test_case(1),
    io:format("~n"),
    io:format("Test stringify() ~n"),
    jarray:test_case(2),
    io:format("~n"),
    io:format("Test parse() ~n"),
    jarray:test_case(3),
    io:format("~n"),
    io:format("~n"),
    io:format("[Work with binary] ~n"),
    io:format("Test test_get_max_deep_binary() ~n"),
    jarray:test_case(4),
    io:format("~n"),
    io:format("Test stringify_binary() ~n"),
    jarray:test_case(5),
    io:format("~n"),
    io:format("Test parse_binary() ~n"),
    jarray:test_case(6),
    io:format("~n").

% jarray:test_case(1). 测试 test get_max_deep()
test_case(Type) when (Type =:= 1) ->
	test_get_max_deep(test_case_get_array());
% jarray:test_case(2). 测试 test j_stringify()
test_case(Type) when (Type =:= 2) ->
	test_j_stringify(test_case_get_array());
% jarray:test_case(3). 测试 test parse()
test_case(Type) when (Type =:= 3) ->
	test_j_parse(test_case_get_array());
% jarray:test_case(4). 测试 test test_get_max_deep_binary()
test_case(Type) when (Type =:= 4) ->
	test_get_max_deep_binary(test_case_get_array());
% jarray:test_case(5). 测试 test stringify_binary()
test_case(Type) when (Type =:= 5) ->
	test_j_stringify_binary(test_case_get_array());
% jarray:test_case(6). 测试 test parse_binary()
test_case(Type) when (Type =:= 6) ->
	test_j_parse_binary(test_case_get_array()).


test_case_get_array() ->
	[
		[
			"case A", 1,
			["哈哈","呵呵"],
			"1#哈哈|呵呵",
			<<"1#哈哈|呵呵">>,
			[<<"哈哈">>,<<"呵呵">>]
		],
		[
			"case B", 2,
			["哈哈",["嘻","嘻"],"呵呵"],
			"2#哈哈||1#嘻|嘻||呵呵",
			<<"2#哈哈||1#嘻|嘻||呵呵">>,
			[<<"哈哈">>,[<<"嘻">>,<<"嘻">>],<<"呵呵">>]
		],
		[
			"case C", 2,
			["哈哈",["嘻"],"呵呵",["嘻","嘻"]],
			"2#哈哈||1#嘻||呵呵||1#嘻|嘻",
			<<"2#哈哈||1#嘻||呵呵||1#嘻|嘻">>,
			[<<"哈哈">>,[<<"嘻">>],<<"呵呵">>,[<<"嘻">>,<<"嘻">>]]
		],
		[
			"case D", 3,
			["哈哈",["嘻","嘻"],"呵呵",["嘻","嘻"],["HO",["HO","HO"]]],
			"3#哈哈|||2#嘻||嘻|||呵呵|||2#嘻||嘻|||2#HO||1#HO|HO",
			<<"3#哈哈|||2#嘻||嘻|||呵呵|||2#嘻||嘻|||2#HO||1#HO|HO">>,
			[<<"哈哈">>,[<<"嘻">>,<<"嘻">>],<<"呵呵">>,[<<"嘻">>,<<"嘻">>],[<<"HO">>,[<<"HO">>,<<"HO">>]]]
		],
		[
			"case E", 5,
			["笔记本",["fish","wood",["fish","wood",["fish","wood",["fish","wood"]]]],"28",["戴尔","N",["A","B"]],["fish","678",["A","B"]]],
			"5#笔记本|||||4#fish||||wood||||3#fish|||wood|||2#fish||wood||1#fish|wood|||||28|||||4#戴尔||||N||||3#A|||B|||||4#fish||||678||||3#A|||B",
			<<"5#笔记本|||||4#fish||||wood||||3#fish|||wood|||2#fish||wood||1#fish|wood|||||28|||||4#戴尔||||N||||3#A|||B|||||4#fish||||678||||3#A|||B">>,
			[<<"笔记本">>,[<<"fish">>,<<"wood">>,[<<"fish">>,<<"wood">>,[<<"fish">>,<<"wood">>,[<<"fish">>,<<"wood">>]]]],<<"28">>,[<<"戴尔">>,<<"N">>,[<<"A">>,<<"B">>]],[<<"fish">>,<<"678">>,[<<"A">>,<<"B">>]]]
		],
		[
			"case F", 5,
			[["fish","666",["A","B"]],"笔记本",["fish","wood",["fish","wood",["fish","wood",["fish","wood"]]]],"28",["戴尔","N",["A","B"]]],
			"5#4#fish||||666||||3#A|||B|||||笔记本|||||4#fish||||wood||||3#fish|||wood|||2#fish||wood||1#fish|wood|||||28|||||4#戴尔||||N||||3#A|||B",
			<<"5#4#fish||||666||||3#A|||B|||||笔记本|||||4#fish||||wood||||3#fish|||wood|||2#fish||wood||1#fish|wood|||||28|||||4#戴尔||||N||||3#A|||B">>,
			[[<<"fish">>,<<"666">>,[<<"A">>,<<"B">>]],<<"笔记本">>,[<<"fish">>,<<"wood">>,[<<"fish">>,<<"wood">>,[<<"fish">>,<<"wood">>,[<<"fish">>,<<"wood">>]]]],<<"28">>,[<<"戴尔">>,<<"N">>,[<<"A">>,<<"B">>]]]
		],
		[
			"case G", 8,
			["A",["A",["A",["A",["",["A",["A",["A","B"],"B"],"B"],"B"],"B"],"B"],"B"],"B"],
			"8#A||||||||7#A|||||||6#A||||||5#A|||||4#||||3#A|||2#A||1#A|B||B|||B||||B|||||B||||||B|||||||B||||||||B",
			<<"8#A||||||||7#A|||||||6#A||||||5#A|||||4#||||3#A|||2#A||1#A|B||B|||B||||B|||||B||||||B|||||||B||||||||B">>,
			[<<"A">>,[<<"A">>,[<<"A">>,[<<"A">>,[<<>>,[<<"A">>,[<<"A">>,[<<"A">>,<<"B">>],<<"B">>],<<"B">>],<<"B">>],<<"B">>],<<"B">>],<<"B">>],<<"B">>]
		],
		[
			"case H", 1,
			["A"],
			"1#A",
			<<"1#A">>,
			[<<"A">>]
		],
		[
			"case I", 2,
			["A",["B"]],
			"2#A||1#B",
			<<"2#A||1#B">>,
			[<<"A">>,[<<"B">>]]
		],
		[
			"case J", 1,
			["丰","26","male","zone.com","javascript,php,css,html,actionscript,erlang,python,ruby"],
			"1#丰|26|male|zone.com|javascript,php,css,html,actionscript,erlang,python,ruby",
			<<"1#丰|26|male|zone.com|javascript,php,css,html,actionscript,erlang,python,ruby">>,
			[<<"丰">>,<<"26">>,<<"male">>,<<"zone.com">>,<<"javascript,php,css,html,actionscript,erlang,python,ruby">>]
		],
		[
			"case K", 1,
			["1","2","3","4","5","漂亮"],
			"1#1|2|3|4|5|漂亮",
			<<"1#1|2|3|4|5|漂亮">>,
			[<<"1">>,<<"2">>,<<"3">>,<<"4">>,<<"5">>,<<"漂亮">>]
		],
		[
			"case L", 2,
			[["1","2"],["3","4"]],
			"2#1#1|2||1#3|4",
			<<"2#1#1|2||1#3|4">>,
			[[<<"1">>,<<"2">>],[<<"3">>,<<"4">>]]
		],
		[
			"case M", 2,
			[["1","2"],["3","4"]],
			"2#1#1|2||1#3|4",
			<<"2#1#1|2||1#3|4">>,
			[[<<"1">>,<<"2">>],[<<"3">>,<<"4">>]]
		],
        [
            "case N", 4,
            ["aa", [["d", "ee", ["jerry"]], "bb", "cc"], [["d", "ee"], "bb", "cc"]],
            "4#aa||||3#2#d||ee||1#jerry|||bb|||cc||||3#2#d||ee|||bb|||cc",
            <<"4#aa||||3#2#d||ee||1#jerry|||bb|||cc||||3#2#d||ee|||bb|||cc">>,
            [<<"aa">>, [[<<"d">>, <<"ee">>, [<<"jerry">>]], <<"bb">>, <<"cc">>], [[<<"d">>, <<"ee">>], <<"bb">>, <<"cc">>]]
        ]
	].

test_get_max_deep(A) ->
	lists:foreach(fun(Every) -> test_echo( lists:nth(1, Every), j_get_max_deep_work_with_string(lists:nth(3, Every), 1, 1), lists:nth(2, Every) ) end, A).
test_j_stringify(A) ->
	lists:foreach(fun(Every) -> test_echo( lists:nth(1, Every), stringify(lists:nth(3, Every)), lists:nth(4, Every) ) end, A).
test_j_parse(A) ->
	lists:foreach(fun(Every) -> test_echo( lists:nth(1, Every), parse(lists:nth(4, Every)), lists:nth(3, Every) ) end, A).
test_get_max_deep_binary(A) ->
    lists:foreach(fun(Every) -> test_echo( lists:nth(1, Every), j_get_max_deep_work_with_binary(lists:nth(6, Every), 1, 1), lists:nth(2, Every) ) end, A).
test_j_stringify_binary(A) ->
	lists:foreach(fun(Every) -> test_echo( lists:nth(1, Every), stringify_binary(lists:nth(6, Every)), lists:nth(5, Every) ) end, A).
test_j_parse_binary(A) ->
	lists:foreach(fun(Every) -> test_echo( lists:nth(1, Every), parse_binary(lists:nth(5, Every)), lists:nth(6, Every) ) end, A).


test_echo(Label, Got, Expect) ->
	if Got =:= Expect ->
			Res = "pass";
		true ->
			Res = "not-pass"
	end,

	if Res =:= "not-pass" ->
			io:format("~p - ~p~n", [Label, Res]),
			io:format("got: "),
			io:format("~p~n", [Got]),
			io:format("expect: "),
			io:format("~p~n", [Expect]),
			io:format("~n");
		true ->
            case get(benchmark) of
                true -> ok;
                _ -> io:format("~p - ~p~n", [Label, Res])
			end
	end.


% jarray:test_stringify_time(100000).  4s
test_stringify_time(N)->
    put(benchmark, true),
    Start = erlang:timestamp(),
    dotimes(N, fun () -> jarray:test_case(2) end),
    % timer:sleep(1000),
    Stop = erlang:timestamp(),
    time_diff(Start, Stop).

% jarray:test_parse_time(100000).  13.672s
test_parse_time(N)->
    put(benchmark, true),
    Start = erlang:timestamp(),
    dotimes(N, fun () -> jarray:test_case(3) end),
    % timer:sleep(1000),
    Stop = erlang:timestamp(),
    time_diff(Start, Stop).

% jarray:test_stringify_binary_time(100000).  5.532s
test_stringify_binary_time(N)->
    put(benchmark, true),
    Start = erlang:timestamp(),
    dotimes(N, fun () -> jarray:test_case(5) end),
    % timer:sleep(1000),
    Stop = erlang:timestamp(),
    time_diff(Start, Stop).

% jarray:test_parse_binary_time(100000).  13.36s
test_parse_binary_time(N)->
    put(benchmark, true),
    Start = erlang:timestamp(),
    dotimes(N, fun () -> jarray:test_case(6) end),
    % timer:sleep(1000),
    Stop = erlang:timestamp(),
    time_diff(Start, Stop).

dotimes(0, _) -> done;
dotimes(N, F) ->
    F(),
    dotimes(N - 1, F).

time_diff({A1,A2,A3}, {B1,B2,B3}) ->
    io:format("~p second ~n" , [(B1 - A1) * 1000000 + (B2 - A2) + (B3 - A3) / 1000000.0]).


anything_to_list(X) ->
	case type_of(X) of
		binary -> binary_to_list(X);
		atom -> atom_to_list(X);
		integer -> integer_to_list(X);
		list -> X;
		tuple -> tuple_to_list(X);
		boolean -> case X of true -> "true"; _ -> "false" end;
		float -> float_to_list(X);
		pid -> pid_to_list(X)
	end.

anything_to_binary(X) ->
	case type_of(X) of
		list -> list_to_binary(X);
		binary -> X;
		atom -> list_to_binary(atom_to_list(X));
		integer -> integer_to_binary(X);
		tuple -> list_to_binary(tuple_to_list(X));
		boolean -> case X of true -> <<"true">>; _ -> <<"false">> end;
		float -> list_to_binary(float_to_list(X));
		pid -> list_to_binary(pid_to_list(X))
	end.
