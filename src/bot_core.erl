-module(bot_core).

-export([start/0]).

start() ->
	Server = "irc.underworld.no",
	Port = 6667,
	{ok, Sock} = gen_tcp:connect(Server, Port, [binary, {packet, 0}, {active, false}]),
	gen_tcp:send(Sock, "NICK Frappebot\r\n"),
	gen_tcp:send(Sock, "USER Frappebot 0 * :Testing bot\r\n"),
	gen_tcp:send(Sock, "JOIN #TJENNA\r\n"),
	%{ok, Bin} = do_recv(Sock, []),
	MsgHandler = spawn(fun() -> msghandler:loop(Sock) end),
	receive_loop(Sock, MsgHandler).

receive_loop(Socket, MsgHandler) ->
	case gen_tcp:recv(Socket, 0) of
		{ok, Data} ->
			MsgHandler ! {message, Data},
			receive_loop(Socket, MsgHandler);
		{error, closed} ->
			closed
	end.
