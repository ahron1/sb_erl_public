%% @doc update_customer_address_handler

-module(update_customer_address_handler).

-export([init/2]).

init(Req0, Opts) ->
	{ok, ReqData, _Req} = cowboy_req:read_body(Req0),

    FireBaseUid = cowboy_req:header(<<"authorization">>, Req0),
	io:format("~n in update customer address handler firebase uid ~n ~p~n", [FireBaseUid]),

	DataDecoded=jsx:decode(ReqData),
	CustomerAddress = maps:get(<<"userAddress">>, DataDecoded),
	GeoAccuracy = maps:get(<<"geoAccuracy">>, DataDecoded),
	CustomerCoordinates = maps:get(<<"userCoordinates">>, DataDecoded),

	#{
		<<"addressLine1">> := AddressLine1, <<"addressLine2">> := AddressLine2, 
		<<"city">> := City, <<"pincode">> := Pincode, <<"state">> := State
	} = CustomerAddress,

	#{<<"latitude">> := Latitude, <<"longitude">> := Longitude} = CustomerCoordinates,
		


    #{num_rows := N} = 
	db_helpers:update_customer_address(
		FireBaseUid, AddressLine1, AddressLine2, City, State, Pincode, Latitude, Longitude, round(GeoAccuracy) ),
	io:format("~n number of rows inserted is:  ~n ~p~n", [N]),
	ReplyContent = case N of 
		1 -> <<"success">>
	end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"text/plain">>
	}, ReplyContent, Req0),
	{ok, Req, Opts}.
