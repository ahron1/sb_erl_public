%% @doc update_store_order_item_handler

-module(update_store_order_item_handler).

-export([init/2]).

init(Req0, Opts) ->
	% io:format("~n Req0 ~n ~p~n", [Req0]),
	{ok, ReqData, _Req} = cowboy_req:read_body(Req0),

    FireBaseUid = cowboy_req:header(<<"authorization">>, Req0),
    StoreId = db_helpers:store_id_given_fbuid(FireBaseUid),
	io:format("~n in update_store_order_items_handler-Store uid ~n ~p~n", [StoreId]),
    % This ^^ information is not used anywhere. But if a malformed request 
    % does not have a customer id, it will crash. 
    % todo: include a check in the db query to return only orders associated with customer id 

	DataDecoded=jsx:decode(ReqData),
	OrderItemId = maps:get(<<"orderItemId">>, DataDecoded),
	OrderItemPrice = maps:get(<<"orderItemPrice">>, DataDecoded),
	OrderItemAvailable = maps:get(<<"orderItemAvailable">>, DataDecoded),

	% io:format("~n in update order item handler order item id ~n ~p~n", [OrderItemId]),
	% io:format("~n in update order item handler order item price ~n ~p~n", [OrderItemPrice]),
	% io:format("~n in update order item handler available ~n ~p~n", [OrderItemAvailable]),

    #{num_rows := N, result := [OrderItem]} = 
		db_helpers:update_order_item(OrderItemId, binary_to_integer(OrderItemPrice), OrderItemAvailable),
	ReplyContent = case N of 
		% 1 -> <<"success">>
		1 -> jsx:encode(OrderItem)
	end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"text/plain">>
	}, ReplyContent, Req0),
	{ok, Req, Opts}.
