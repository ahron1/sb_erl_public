%% @doc get_users_in_state_handler

-module(get_users_in_state_handler).
-export([init/2]).

init(Req0, Opts) ->
	{ok, ReqData, _Req} = cowboy_req:read_body(Req0),
	io:format("~n  in get_users_in_state ReqData ~n ~p~n", [ReqData]),

     #{num_rows := N, result := Users} = 
        db_helpers:get_users_in_state(ReqData),
    Reply2 = case N of 
        0 -> 
            jsx:encode(Users);
        _ ->
            jsx:encode(Users)
    end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json">>
	}, Reply2, Req0),
	{ok, Req, Opts}.
