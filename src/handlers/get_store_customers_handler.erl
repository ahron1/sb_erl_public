%% @doc get_customers_referred_by_store_handler

-module(get_store_customers_handler).
-export([init/2]).

init(Req0, Opts) ->
    FireBaseUid = cowboy_req:header(<<"authorization">>, Req0),
	io:format("~n in get_customers referred by store auth uid ~n ~p~n", [FireBaseUid]),

    StoreId = db_helpers:store_id_given_fbuid(FireBaseUid),
	io:format("~n  in get_customers referred by store uid ~n ~p~n", [StoreId]),

    #{num_rows := N, customers := Customers} = 
        % db_helpers:customers_given_store(StoreId),
        db_helpers:referred_customers_given_store(StoreId),
    Reply2 = 
        case N of 
        0 -> 
            jsx:encode(Customers);
        _ ->
            jsx:encode(Customers)
    end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json">>
	}, Reply2, Req0),
	{ok, Req, Opts}.
