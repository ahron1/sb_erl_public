%% @doc delete_order_handler

-module(delete_order_handler).
-export([init/2]).

init(Req0, Opts) ->
    FireBaseUid = cowboy_req:header(<<"authorization">>, Req0),
	io:format("~n in delete_order_handler- auth firebase uid ~n ~p~n", [FireBaseUid]),

	#{orderId := OrderId} = cowboy_req:match_qs([orderId], Req0),
    io:format("~n in delete_order_handler- order  id ~n ~p~n", [OrderId]),

    #{num_rows := N} = 
        db_helpers:delete_order_given_id(OrderId),
    io:format("~n in delete order  handler. n of rows ~n ~p~n", [N]),
    Reply2 = case N of 
        1 -> 
            <<"success">>
    end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json">>
	}, Reply2, Req0),
	{ok, Req, Opts}.
