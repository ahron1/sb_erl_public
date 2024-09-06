%% @doc store_confirm_order_handler

-module(store_confirm_order_handler).
-export([init/2]).

init(Req0, Opts) ->
    % FireBaseUid = cowboy_req:header(<<"authorization">>, Req0),

	{ok, ReqData, _Req} = cowboy_req:read_body(Req0),

	DataDecoded=jsx:decode(ReqData),

	OrderId = maps:get(<<"orderId">>, DataDecoded),
	io:format("~n in store confirm order handler. order id is ~n ~p~n", [OrderId]),

    #{num_rows := N} = 
        db_helpers:store_confirm_order(OrderId),

    Reply2 = case N of 
        1 -> 
			<<"success">>
    end,

	CustomerFcmToken = db_helpers:customer_fcm_given_order_id(OrderId),
	StoreName = db_helpers:store_name_given_order_id(OrderId),

	Title = <<"Order confirmed on Storebhai">>,
	ConfirmText = <<" has confirmed your order on Storebhai. The store will fulfil the order soon.">>,
	Body = <<StoreName/binary, ConfirmText/binary >>,

	Notification = #{ 
		title => Title, 
		body => Body
	},
	Message = #{ notification => Notification },
	try [{_MessageId, _FcmPid}] = fcm:push(fcm_storebhai, CustomerFcmToken, Message, foo) of 
		_ -> 
			io:format("~n  in confirm order handler notification sent:  ~n  ~n" ),
			ok
	catch 
		_:_ -> 
			io:format("~n  in confirm order handler notification NOT sent:  ~n  ~n"  ),
			ok
	end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json">>
	}, Reply2, Req0),
	{ok, Req, Opts}.
