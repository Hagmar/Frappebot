-module(msghandler).

-export([loop/1]).

loop(Sock) ->
	receive
		{message, Data} ->
			io:format("~ts", [Data]),
			spawn(fun() -> process_msg(Data, Sock) end),
			loop(Sock);
		_ ->
			loop(Sock)
	end.

process_msg(<<"PING :", Data/binary>>, Sock) ->
	send("PONG :" ++ Data, Sock);

process_msg(BinaryData, Sock) ->
	case binary:split(BinaryData, <<" ">>) of
		[Prefix | Message] ->
			io:format("Prefix: ~p~nMessage: ~p~n", [Prefix, Message]);
		_ ->
			io:format("no~n")
	end;

process_msg(_, _) ->
	ok.

send(Data, Sock) ->
	io:format("Sending ~p~n", [Data]),
	gen_tcp:send(Sock, Data).
