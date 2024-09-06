%% @doc add_order_item_handler.

-module(add_order_item_handler).
-export([init/2]).

init(Req0, Opts) ->
	{ok, ReqData, _Req} = cowboy_req:read_body(Req0),
	DataDecoded=jsx:decode(ReqData),
	OrderId = maps:get(<<"orderId">>, DataDecoded),
	OrderName = maps:get(<<"name">>, DataDecoded),
	OrderQuantity = maps:get(<<"quantity">>, DataDecoded),
	io:format("~n in add order item handler. orderid  ~n ~p~n", [OrderId]),
	io:format("~n in add order item handler. order name  ~n ~p~n", [OrderName]),
	io:format("~n in add order item handler. order qty  ~n ~p~n", [OrderQuantity]),


    #{num_rows := N, order_item_id := OrderItemId} = 
        db_helpers:add_order_item(OrderName, OrderQuantity, OrderId),
    io:format("~n in add order item handler. n of rows ~n ~p~n", [N]),
    io:format("~n in add order item handler. new order item id ~n ~p~n", [OrderItemId]),
    Reply2 = case N of 
        1 -> 
            integer_to_binary(OrderItemId)
    end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json">>
	}, Reply2, Req0),
	{ok, Req, Opts}.
