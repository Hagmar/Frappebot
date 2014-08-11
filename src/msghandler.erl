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

process_msg(_, _) ->
	io:format("TJENNAAA"),
	ok.

send(Data, Sock) ->
	io:format("Sending ~p~n", [Data]),
	gen_tcp:send(Sock, Data).
