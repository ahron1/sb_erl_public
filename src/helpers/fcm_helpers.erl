-module(fcm_helpers).
-export([send_seller_notification/2]).

send_notification(FcmToken, Message, FcmSender) ->
    try [{_MessageId, _FcmPid}] = fcm:push(FcmSender, FcmToken, Message, foo) of 
        [{_, {error, {_Code, _}}}] ->
			% io:format("~n  in send notification sent to token error:  ~n ~p ~p ~n", [FcmToken, Code] ),
            ok;
		_ -> 
			% io:format("~n  in send notification sent to token :  ~n ~p  ~n", [FcmToken] ),
			ok
	catch 
		_:_ -> 
			% io:format("~n  in send notification NOT sent to token:  ~n ~p  ~n", [FcmToken]  ),
			ok
	end.

send_seller_notification(FcmTokens, Message) ->
    lists:foreach(
        fun(Element) -> 
            Token = maps:get(fcm_token, Element),
            ok = send_notification(Token, Message, fcm_storebhai_manager) end,
        FcmTokens).

