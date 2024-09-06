%% @doc customer_account_handler

-module(customer_account_handler).

-export([init/2]).

init(Req0, Opts) ->
	{ok, ReqData, _Req} = cowboy_req:read_body(Req0),
	DataDecoded=jsx:decode(ReqData),
	FirebaseUid = maps:get(<<"fireBaseUid">>, DataDecoded),
	FcmToken = maps:get(<<"fcmToken">>, DataDecoded),
	MobileNumber = maps:get(<<"phoneNumber">>, DataDecoded),
	io:format("~n in customer account handler FirebaseUid ~n ~p~n", [FirebaseUid]),
	io:format("~n  in customer account handler FcmToken ~n ~p~n", [FcmToken]),
	io:format("~n  in customer account handler MobileNumber ~n ~p~n", [MobileNumber]),
	N = db_helpers:log_in_user(FirebaseUid, FcmToken, MobileNumber),
	io:format("~n  in customer account handler number of rows inserted is:  ~n ~p~n", [N]),

	Reply2 = case N of 
        0 -> 
           <<"Your details are updated">>;
        1 -> 

%			Notification = #{ title => <<"Welcome to Storebhai">>, body => <<"Welcome to Storebhai. Find local stores and send them your orders. Contact us for any problems. Have a good experience!">>},
%			% Data = #{alert_title => <<"Welcome to Storebhai">>, alert_body => <<"Welcome to Storebhai. Find local stores and send them your orders. Contact us for any problems. Have a good experience!">> },
%
%			AndroidPayload = #{ 
%				notification => #{
%					image => <<"https://i.pinimg.com/originals/33/b8/69/33b869f90619e81763dbf1fccc896d8d.jpg">> } 
%			},
% 
%			% Message = #{ notification => Notification},
%			% Message = #{ data => Data},
%			% Message = #{ notification => Notification, data => Data},
%			Message = #{ notification => Notification, android => AndroidPayload},
%			% Message = #{ notification => Notification, data => Data, android => AndroidPayload},
%			% Message = #{ android => AndroidPayload, data => Data},
% 
%			% to test the try catch and timeouts - do this in the previous case block
%			% enable the timer, and after the last ^ message is logged to console, disable internet
%			% to test the try catch with wrong values - do this in the previous case block
%			% use the func call with the malformed FcmToken value
%			% Foo = <<"12345">>,
%			% io:format("~n wait start ~n"),
%			% timer:sleep(7000),
%
%			% try _ = fcm:push(fcm_storebhai, <<FcmToken/binary, Foo/binary >>, Message, foo) of 
%			try [{_MessageId, _FcmPid}] = fcm:push(fcm_storebhai_manager, FcmToken, Message, foo) of 
%				_ -> 
%					io:format("~n  in store account handler notification sent:  ~n  ~n" ),
%					ok
%			catch 
%				_:_ -> 
%				io:format("~n  in store account handler notification NOT sent:  ~n  ~n"  )
%			end,

           <<"Your details are registered">>
    end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"text/plain">>
	}, Reply2, Req0),
	{ok, Req, Opts}.
