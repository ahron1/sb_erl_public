%% @doc get_stores_handler

-module(get_states_handler).
-export([init/2]).

init(Req0, Opts) ->
    % FireBaseUid = cowboy_req:header(<<"authorization">>, Req0),
	% io:format("~n in get_orders_handler auth uid ~n ~p~n", [FireBaseUid]),

    % CustomerId = db_helpers:customer_id_given_fbuid(FireBaseUid),
	% io:format("~n  in get_orders_handler customer uid ~n ~p~n", [CustomerId]),

    % FcmToken = db_helpers:fcm_token_given_customer_id(CustomerId),

    #{num_rows := N, result := States} = 
        db_helpers:get_states_list(),
    Reply2 = case N of 
        0 -> 
            jsx:encode(States);
        _ ->
            jsx:encode(States)
    end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json">>
	}, Reply2, Req0),
	{ok, Req, Opts}.
