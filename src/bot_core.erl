-module(bot_core).

-export([start/0, start/1, start/2]).

start() ->
	start("irc.underworld.no", 6667).

start(Server) ->
	start(Server, 6667).

start(Server, Port) ->
	case gen_tcp:connect(Server, Port, [binary, {packet, 0}, {active, false}]) of
		{ok, Sock} ->
			gen_tcp:send(Sock, "NICK Frappebot\r\n"),
			gen_tcp:send(Sock, "USER Frappebot 0 * :Testing bot\r\n"),
			gen_tcp:send(Sock, "JOIN #TJENNA\r\n"),
			MsgHandler = spawn(fun() -> msghandler:loop(Sock) end),
			receive_loop(Sock, MsgHandler);
		_ ->
			error
	end.
	

receive_loop(Socket, MsgHandler) ->
	case gen_tcp:recv(Socket, 0) of
		{ok, Data} ->
			MsgHandler ! {message, Data},
			receive_loop(Socket, MsgHandler);
		{error, closed} ->
			closed
	end.
