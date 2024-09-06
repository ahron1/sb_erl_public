%% @doc add_loyalty_code_customer_handler

-module(add_loyalty_code_customer_handler).

-export([init/2]).

init(Req0, Opts) ->
	% io:format("~n Req0 ~n ~p~n", [Req0]),
	{ok, ReqData, _Req} = cowboy_req:read_body(Req0),


    FireBaseUid = cowboy_req:header(<<"authorization">>, Req0),
	io:format("~n in add loyalty code handler firebase uid ~n ~p~n", [FireBaseUid]),

	DataDecoded=jsx:decode(ReqData),
	% io:format("~n in add loyalty code handler data is ~n ~p~n", [DataDecoded]),
	% LoyaltyCode = maps:get(<<"loyaltyCode">>, DataDecoded),
	% Category = maps:get(<<"category">>, DataDecoded),
	Object = maps:get(<<"object">>, DataDecoded),

    #{num_rows := N, loyalty_code := LoyaltyCode} = 
	db_helpers:add_loyalty_code_customer(FireBaseUid, Object),

	io:format("~n in add loyalty code returned from DB is ~n ~p ~n", [LoyaltyCode]),
	ReplyContent = case N of 
		% 1 -> <<"success">>
		1 -> LoyaltyCode
	end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"text/plain">>
	}, ReplyContent, Req0),
	{ok, Req, Opts}.
