%% @doc add_order_handler.
-module(add_order_handler).
-export([init/2]).

init(Req0, Opts) ->
    FireBaseUid = cowboy_req:header(<<"authorization">>, Req0),
	io:format("~n in add_order_item_handler- auth uid ~n ~p~n", [FireBaseUid]),

    CustomerId = db_helpers:customer_id_given_fbuid(FireBaseUid),
	io:format("~n in add_order_item_handler- customer uid ~n ~p~n", [CustomerId]),

    %#{category := Category} = cowboy_req:match_qs([{category, [], <<"grocery">>}], Req0),
    #{category := Category, store_id := StoreId} = cowboy_req:match_qs([{category, [], <<"storebhai">>}, {store_id, [], <<"none">>}], Req0),
    % store_id "none" is to identify new orders from old storebhai app - where the store is specified at the last step.

	io:format("~n in add_order_item_handler- query param order category is ~n ~p~n", [Category]),
	io:format("~n in add_order_item_handler- query param order storeid is ~n ~p~n", [StoreId]),

    #{num_rows := N, order := Order} = 
    case StoreId of 
        <<"none">> ->
            io:format("~n no store specified ~n"),
            db_helpers:add_order(CustomerId, Category);
        _ ->
            io:format("~n store id specified ~n"),
            db_helpers:add_order(CustomerId, Category, erlang:binary_to_integer(StoreId))
    end,

    io:format("~n in add order handler. n of rows ~n ~p~n", [N]),
    %io:format("~n in add order handler. new order  ~n ~p~n", [Order]),
    Reply2 = case N of 
        1 -> 
            jsx:encode(Order)
    end,

	% timer:sleep(2000),
	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json">>
	}, Reply2, Req0),
	{ok, Req, Opts}.
