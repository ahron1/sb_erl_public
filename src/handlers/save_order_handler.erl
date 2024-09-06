%% @doc add_order_item_handler.

-module(save_order_handler).

-export([init/2]).

init(Req0, Opts) ->
	% io:format("~n Req0 ~n ~p~n", [Req0]),
	{ok, ReqData, _Req} = cowboy_req:read_body(Req0),

    FireBaseUid = cowboy_req:header(<<"authorization">>, Req0),
    %io:format("~n in save order handler -firebase uid ~n ~p~n", [FireBaseUid]),
    IsValidUser = case db_helpers:check_valid_user(FireBaseUid) of
                      1 -> true;
                      _ -> false
                  end,
   
	DataDecoded=jsx:decode(ReqData),
	OrderId = maps:get(<<"orderId">>, DataDecoded),
	OrderDetail = jsx:encode(maps:get(<<"orderDetail">>, DataDecoded)),

%    io:format("~n in save order handler order id ~n ~p~n", [OrderId ]),
%    io:format("~n in save order handler OrderDetail  ~n ~p~n", [OrderDetail  ]),

    #{num_rows := N} = case IsValidUser of
                           true -> db_helpers:save_order(OrderId, OrderDetail)
                       end,

	ReplyContent = case N of 
		 1 -> <<"success">>
	end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"text/plain">>
	}, ReplyContent, Req0),
	{ok, Req, Opts}.
