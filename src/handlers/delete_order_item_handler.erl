%% @doc delete_order_item_handler

-module(delete_order_item_handler).
-export([init/2]).

init(Req0, Opts) ->
    FireBaseUid = cowboy_req:header(<<"authorization">>, Req0),
	io:format("~n in delete_order_item_handler- auth uid ~n ~p~n", [FireBaseUid]),

	#{orderItemId := OrderItemId} = cowboy_req:match_qs([orderItemId], Req0),
    io:format("~n in delete_order_item_handler- order Item id ~n ~p~n", [OrderItemId]),

    #{num_rows := N} = 
        db_helpers:delete_order_item_given_id(OrderItemId),
    io:format("~n in delete order item handler. n of rows ~n ~p~n", [N]),
    Reply2 = case N of 
        1 -> 
            <<"success">>
    end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json">>
	}, Reply2, Req0),
	{ok, Req, Opts}.
