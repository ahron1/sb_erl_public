%% @doc get_default_store_handler

-module(get_default_store_handler).
-export([init/2]).

init(Req0, Opts) ->
    FireBaseUid = cowboy_req:header(<<"authorization">>, Req0),

    CustomerId = db_helpers:customer_id_given_fbuid(FireBaseUid),
	io:format("~n in get stores handler - customer uid ~n ~p~n", [CustomerId]),

    #{num_rows := N, default_store := DefaultStore} = 
        db_helpers:default_store_given_customer_uid(FireBaseUid),
    io:format("~n in get default stores handler. now of rows of default stores ~n ~p~n", [N]),

    Reply2 = case N of 
        1 -> 
            jsx:encode(DefaultStore);
        _ ->
            #{num_rows := M, stores := Stores} = 
                db_helpers:stores_given_customer_id(CustomerId),
            io:format("~n in get default stores handler. now of rows of stores ~n ~p~n", [M]),
            case M of 
                0 -> 
                    jsx:encode(Stores);
                _ ->
                    jsx:encode(Stores)
            end
    end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json">>
	}, Reply2, Req0),
	{ok, Req, Opts}.
