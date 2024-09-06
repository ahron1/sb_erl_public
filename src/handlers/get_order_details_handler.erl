%% @doc get_order_details_handler

-module(get_order_details_handler).
-export([init/2]).

init(Req0, Opts) ->
    FireBaseUid = cowboy_req:header(<<"authorization">>, Req0),
    IsValidUser = case db_helpers:check_valid_user(FireBaseUid) of
                      1 -> true;
                      _ -> false
                  end,
 
	#{orderId := OrderId} = cowboy_req:match_qs([orderId], Req0),
    io:format("~n in get_order_details_handler-order id ~n ~p~n", [OrderId]),

    #{num_rows := N, order_details := OrderDetails} = 
        case IsValidUser of
            true ->
                db_helpers:order_details_given_order_id(OrderId)
        end,

    io:format("~n in get_order_details_handler-order details ~n ~p~n", [OrderDetails]),

    Reply2 = case N of 
        0 -> 
            jsx:decode(OrderDetails);
        _ ->
            %jsx:decode(OrderDetails)
            OrderDetails
    end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json">>
	}, Reply2, Req0),
	{ok, Req, Opts}.
