%% @doc store_delete_customer_handler

-module(store_delete_customer_handler).
-export([init/2]).

init(Req0, Opts) ->
	{ok, ReqData, _Req} = cowboy_req:read_body(Req0),

    FireBaseUid = cowboy_req:header(<<"authorization">>, Req0),
	io:format("~n in store_delete_customer handler auth uid ~n ~p~n", [FireBaseUid]),

    StoreId = db_helpers:store_id_given_fbuid(FireBaseUid),
	io:format("~n  in store_delete_customer handler store uid ~n ~p~n", [StoreId]),

	DataDecoded=jsx:decode(ReqData),

	CustomerNumber = maps:get(<<"customerNumber">>, DataDecoded),
	io:format("~n in store_delete_customer  handler. customer number is ~n ~p~n", [CustomerNumber]),

    #{num_rows := N} = 
        db_helpers:store_delete_customer(StoreId, CustomerNumber),
    Reply2 = case N of 
        1 -> 
			<<"success">>
    end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json">>
	}, Reply2, Req0),
	{ok, Req, Opts}.
