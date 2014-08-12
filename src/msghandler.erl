-module(msghandler).

-export([loop/1]).

loop(Sock) ->
	receive
		{message, Data} ->
			io:format("~p~n", [binary_to_list(Data)]),
			spawn(fun() -> process_msg(Data, Sock) end),
			loop(Sock);
		_ ->
			loop(Sock)
	end.

process_msg(<<"PING :", Data/binary>>, Sock) ->
	send("PONG :" ++ Data, Sock);

process_msg(BinaryData, Sock) ->
	case binary:split(BinaryData, <<" ">>) of
		[Prefix | [Message | [] ]] ->
			io:format("Prefix: ~p~nMessage: ~p~n", [Prefix, Message]),
			handle_message(Prefix, Message, Sock);
		_ ->
			io:format("no~n")
	end;

process_msg(_, _) ->
	ok.

handle_message(<<":", Prefix/binary>>, <<"JOIN :", Channel/binary>>, Sock) ->
	[User | [Host | [] ]] = binary:split(Prefix, <<"!">>),
	ChannelName = stripCtrl(binary_to_list(Channel)),
	Msg = "MODE " ++ ChannelName ++ " +v " ++ binary_to_list(User) ++ "\r\n",
	send(Msg, Sock);

handle_message(_, Aee, _) ->
	io:format("~p~n", [Aee]).

send(Data, Sock) ->
	io:format("Sending ~p~n", [Data]),
	gen_tcp:send(Sock, Data).

stripCtrl(Data) ->
	string:strip(string:strip(Data, right, $\n), right, $\r).
