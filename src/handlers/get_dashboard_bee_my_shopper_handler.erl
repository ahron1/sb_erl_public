%% @doc get_dashboard_bee_my_shopper_handler

-module(get_dashboard_bee_my_shopper_handler).
-export([init/2]).

init(Req0, Opts) ->
    % FireBaseUid = cowboy_req:header(<<"authorization">>, Req0),
	% io:format("~n in get_orders_handler auth uid ~n ~p~n", [FireBaseUid]),

    % CustomerId = db_helpers:customer_id_given_fbuid(FireBaseUid),
	io:format("~n  in bee my shopper dashboard customer uid ~n ~n"),

    % FcmToken = db_helpers:fcm_token_given_customer_id(CustomerId),

    #{num_rows := N, result := Orders} = 
        db_helpers:orders_by_store_2(599, 365),
    Reply2 = case N of 
        0 -> 
            jsx:encode(Orders);
        _ ->
            jsx:encode(Orders)
    end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json">>
	}, Reply2, Req0),
	{ok, Req, Opts}.
