%% @doc update_store_name_handler

-module(update_store_name_handler).

-export([init/2]).

init(Req0, Opts) ->
	% io:format("~n Req0 ~n ~p~n", [Req0]),
	{ok, ReqData, _Req} = cowboy_req:read_body(Req0),

    FireBaseUid = cowboy_req:header(<<"authorization">>, Req0),
	io:format("~n in update store name handler firebase uid ~n ~p~n", [FireBaseUid]),

	DataDecoded=jsx:decode(ReqData),
	StoreName = maps:get(<<"userName">>, DataDecoded),

    #{num_rows := N} = 
	db_helpers:update_store_name(StoreName, FireBaseUid),
	ReplyContent = case N of 
		1 -> <<"success">>
	end,

	Req = cowboy_req:reply(200, #{
		<<"content-type">> => <<"text/plain">>
	}, ReplyContent, Req0),
	{ok, Req, Opts}.
