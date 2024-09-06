%% @doc get_order_items_handler

-module(get_order_items_handler).
-export([init/2]).

init(Req0, Opts) ->
    FireBaseUid = cowboy_req:header(<<"authorization">>, Req0),

    CustomerId = db_helpers:customer_id_given_fbuid(FireBaseUid),
	io:format("~n in get_order_items_handler-customer uid ~n ~p~n", [CustomerId]),
    % This ^^ information is not used anywhere. But if a malformed request 
    % does not have a customer id, it will crash. 
    % todo: include a check in the db query to return only orders associated with customer id 

	#{orderId := OrderId} = cowboy_req:match_qs([orderId], Req0),
    io:format("~n in get_order_items_handler-order id ~n ~p~n", [OrderId]),

    #{num_rows := N, order_items := OrderItems} = 
        db_helpers:order_items_given_order_id(OrderId),
    Reply2 = case N of 
        0 -> 
            jsx:encode(OrderItems);
        _ ->
            jsx:encode(OrderItems)
    end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json">>
	}, Reply2, Req0),
	{ok, Req, Opts}.
