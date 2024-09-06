%% @doc payment made handler

-module(payment_made_handler).
-export([init/2]).

init(Req0, Opts) ->
	{ok, ReqData, _Req} = cowboy_req:read_body(Req0),

	DataDecoded=jsx:decode(ReqData),

	OrderId = maps:get(<<"orderId">>, DataDecoded),
	IsPaymentCash = maps:get(<<"isPaymentCash">>, DataDecoded),
	IsPaymentOnline = maps:get(<<"isPaymentOnline">>, DataDecoded),
	IsPaymentCredit = maps:get(<<"isPaymentCredit">>, DataDecoded),
	Amount = maps:get(<<"amount">>, DataDecoded),
	io:format("~n in payment made handler. order id is ~n ~p~n", [OrderId]),

    #{num_rows := N, order := Order} = 
        db_helpers:payment_made(OrderId, IsPaymentCash, IsPaymentOnline, IsPaymentCredit, Amount),
    Reply2 = case N of 
        1 -> 
            jsx:encode(Order)
    end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json">>
	}, Reply2, Req0),
	{ok, Req, Opts}.
