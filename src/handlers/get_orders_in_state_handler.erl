%% @doc get_stores_in_state_handler

-module(get_orders_in_state_handler).
-export([init/2]).

init(Req0, Opts) ->
	{ok, ReqData, _Req} = cowboy_req:read_body(Req0),
	io:format("~n  in get_orders_in_state ReqData ~n ~p~n", [ReqData]),

     #{num_rows := N, result := Orders} = 
        db_helpers:get_orders_in_state(ReqData),
        % db_helpers:get_orders_in_state_list(<<"Odisha">>),

	% io:format("~n  in get_orders_in_state Orders ~n p~n", [Orders]),
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
