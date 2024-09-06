%% @doc send_order_handler

-module(send_order_handler).
-export([init/2]).

init(Req0, Opts) ->
    % StoreAuthUid = cowboy_req:header(<<"authorization">>, Req0),
	{ok, ReqData, _Req} = cowboy_req:read_body(Req0),

	DataDecoded=jsx:decode(ReqData),

	OrderId = maps:get(<<"orderId">>, DataDecoded),
	StoreId = maps:get(<<"storeId">>, DataDecoded),
	IsPickup = maps:get(<<"isPickup">>, DataDecoded),
	IsDelivery = maps:get(<<"isDelivery">>, DataDecoded),
	OrderComment = maps:get(<<"orderComment">>, DataDecoded),
	io:format("~n in send order handlers. order id is ~n ~p~n", [OrderId]),
	io:format("~n in send order handlers. order comment is ~n ~p~n", [OrderComment]),

    #{num_rows := N, order := Order} = 
        db_helpers:link_store_to_order(OrderId, StoreId, IsPickup, IsDelivery, OrderComment),
    Reply2 = case N of 
        1 -> 
            jsx:encode(Order)
    end,

	% FcmToken = 
		% db_helpers:store_fcm_given_id(StoreId),

	FcmTokens = 
		db_helpers:store_fcms_given_id(StoreId),

	Notification = #{ 
		title => <<"New Order on Storebhai">>, 
		body => <<"You have a new order on Storebhai. Please update the prices and confirm the order, and fulfill the order quickly.">>
	},
	Message = #{ notification => Notification },

	% try [{_MessageId, _FcmPid}] = fcm:push(fcm_storebhai_manager, FcmToken, Message, foo) of 
		% _ -> 
			% io:format("~n  in send order handler notification sent:  ~n  ~n" ),
			% ok
	% catch 
		% _:_ -> 
			% io:format("~n  in send order handler notification NOT sent:  ~n  ~n"  ),
			% ok
	% end,

	ok = fcm_helpers:send_seller_notification(FcmTokens, Message),

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json">>
	}, Reply2, Req0),
	{ok, Req, Opts}.
