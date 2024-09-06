%% @doc store_confirm_fulfil_handler

-module(store_confirm_fulfil_handler).
-export([init/2]).

init(Req0, Opts) ->
	{ok, ReqData, _Req} = cowboy_req:read_body(Req0),

	DataDecoded=jsx:decode(ReqData),

	OrderId = maps:get(<<"orderId">>, DataDecoded),
	io:format("~n in store confirm fulfil handler. order id is ~n ~p~n", [OrderId]),

    #{num_rows := N} = 
        db_helpers:store_confirm_fulfil(OrderId),
    Reply2 = case N of 
        1 -> 
			<<"success">>
    end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json">>
	}, Reply2, Req0),
	{ok, Req, Opts}.
