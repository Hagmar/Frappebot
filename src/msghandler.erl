-module(msghandler).

-export([loop/1]).

loop(Sock) ->
	receive
		{message, Data} ->
			io:format("NEW MESSAGE"),
			io:format("~ts", [Data]),
			loop(Sock);
		_ ->
			gjf
	end.
