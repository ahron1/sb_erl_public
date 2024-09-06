%% @doc get_store_details_handler

-module(get_store_details_handler).
-export([init/2]).

init(Req0, Opts) ->
    FirebaseUid = cowboy_req:header(<<"authorization">>, Req0),
	io:format("~n in get store details handler- auth uid ~n ~p~n", [FirebaseUid]),

    #{ 
        num_rows := N, username := UserName, 
        address_line1 := AddressLine1, address_line2 := AddressLine2, 
        city := City, state := State, pincode := Pincode, 
        latitude := Latitude, longitude := Longitude,
        offers_pickup := OffersPickup, offers_delivery := OffersDelivery,
        delivery_radius := DeliveryRadius, payment_online := PaymentOnline,
        payment_cash := PaymentCash, payment_credit := PaymentCredit, upi_id := UpiId
    } = 
        db_helpers:store_details_given_firebase_uid(FirebaseUid),
    io:format("~n in get store details handler user name ~n ~p~n", [UserName]),
    Reply2 = case N of 
        0 -> 
            <<"error">>;
        1 ->
            jsx:encode(#{ 
                username => UserName, address_line1 => AddressLine1, 
                address_line2 => AddressLine2, city => City,
                state => State, pincode => Pincode,
                latitude => Latitude, longitude => Longitude,
                offers_pickup => OffersPickup, offers_delivery => OffersDelivery,
                delivery_radius => DeliveryRadius, payment_online => PaymentOnline,
                payment_cash => PaymentCash, payment_credit => PaymentCredit, upi_id => UpiId
            })
    end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json">>
	}, Reply2, Req0),
	{ok, Req, Opts}.
