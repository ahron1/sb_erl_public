%% Feel free to use, reuse and abuse the code in this file.
%%
%% sends a dummy json output based on a (hardcoded) db query
%% sends a dummy (hardcoded)notification to the test device. 
%% todo - update ^^ and use notifications in the right places

%% @doc Hello world handler.
-module(hello_handler).

-export([init/2]).

init(Req0, Opts) ->
	% io:format("~n Req0 ~n ~p~n", [Req0]),
%	Reply1 = <<"Hey worldie!">>,

	%RegId = <<"cdcM8LWHSSy29TcJHM4Ba5:APA91bF2rxQFJ1U084rqNeUmqiU92nAtt7GSc90pcWhOMRM7aZ9rys7ou9B9m9BNDMOlGsbi7oCmtOVdBQJkn2eATGLvdITCVP7nk5cVUwAuUjaYQ0LB8bYcBPKA3LFiKZ3_IiQPOMvD">>,
	%Notification = #{ title => <<"message title">>, body => <<"message body">>},
	%AndroidPayload = #{ notification => #{image => <<"https://i.pinimg.com/originals/33/b8/69/33b869f90619e81763dbf1fccc896d8d.jpg">> } },
	%Data = #{data_item1 => <<"This is the data">>, data_item2 => <<"This is the other data">> },
	%Message = #{ notification => Notification, android => AndroidPayload, data => Data },
	%Message = #{ data => Data },
	% the foo atom is irrelevant for the v1 API and used only as a filler. In the legacy API, it had to have a legit value. Check docs. 
	%[{RegId, MessageId}] = fcm:push(test, RegId, Message, foo),
	%io:format("~n FCM PUSH ~n ~p~n", [MessageId]),

	% Notification = #{ 
        % title => <<"message title">>, 
        % body => <<"message body">>
    % },
	% AndroidPayload = #{ 
        % notification => #{image => <<"https://i.pinimg.com/originals/33/b8/69/33b869f90619e81763dbf1fccc896d8d.jpg">> } 
    % },
	% Data = #{
        % data_item1 => <<"This is the data">>, 
        % data_item2 => <<"This is the other data">> 
    % },
	% Message = #{ 
        % notification => Notification, 
        % android => AndroidPayload, 
        % data => Data 
    % },
	%% Message = #{ data => Data },
	%% the foo atom is irrelevant for the v1 API and used only as a filler. In the legacy API, it had to have a legit value. Check docs. 
	% [{_, MessageId}] = fcm:push(test, FcmToken, Message, foo),
	% io:format("~n FCM PUSH ~n ~p~n", [MessageId]),

	%R = pgo:query("select (order_id, order_price, customer, store) from orders"),
	%#{ rows := Orders } = R,

	%io:format("~n Orders ~n ~p~n", [Orders]),
	%O1 = lists:nth(1, Orders),
	%{{OrderId1, OrderPrice1, Store1, Customer1}} = O1,
	%Order1Map = #{ order_id => OrderId1, order_price => OrderPrice1, store => Store1, customer => Customer1 },
	%Reply2 = jsx:encode(Order1Map),
	%
	% QueryResult = pgo:query("select * from order_item", [], #{decode_opts => [return_rows_as_maps]}),
	QueryResult = db_helpers:get_all_user_names(),
	% #{ rows := OrderItems } = QueryResult,
	% Reply2 = jsx:encode(OrderItems),
	Reply2 = <<"foo">>,
	io:format("~n Query result ~n ~p~n", [QueryResult]),

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"application/json">>
	}, Reply2, Req0),
%		<<"content-type">> => <<"text/plain">>
%	}, <<"Howdie world!">>, Req0),
%	}, Reply1, Req0),
%	io:format("Req ~n ~p~n", [Req]),
	{ok, Req, Opts}.
