-module(udp_test).
-export([server/1]).
-export([client/1]).
-export([client/3]).
-export([startclient/0]).
-export([startserver/0]).



startserver() ->
    spawn(udp_test, server, [53530]).

server(Port) ->
    {ok,Socket} = gen_udp:open(Port,[binary]),
    loop(Socket).
% Define the server side behavior.
loop(Socket) ->
    receive
        {udp,Socket,Host,Port,Bin} ->
            gen_udp:send(Socket,Host,Port,Bin),
            io:format("~s~n",[Bin]),
            loop(Socket)
     end.
% Here server receives message prints it and sends back a response using the exactly
% the same message from client side. Then loop for next message.


%Define interface to create client side.
%This one client/1 is used for test. Simple one.
client(Request) ->
    {ok,Socket} = gen_udp:open(0,[binary]),
    ok = gen_udp:send(Socket,"10.175.13.204",53530,Request),
    Value = receive
                {udp,Socket,_,_,Bin} ->
                    {ok,Bin}
                after 2000 ->
                    error
                end,
    gen_udp:close(Socket),
    Value.


%Define client/3
client(Host, Port, Request) ->
    {ok,Socket} = gen_udp:open(0,[binary]),
     Id = 1,
     loopclient(Socket, Host, Port, Request, Id + 1).   
% Define that the client will send message for 8 times then quit.
loopclient(Socket, Host, Port, Request1, Id) when Id < 10 ->
    ok = gen_udp:send(Socket,Host,Port,Request1),
     loopclient(Socket,Host, Port, Request1, Id + 1);
loopclient(Socket, Host, Port, Request1, Id) ->
     gen_udp:close(Socket),
     done.


% Define interface to start several clients at the same time by using spawn.
% Here I defined 14 processes to simulate 5 concurrent clients. Each one will send 10
% UDP packages.
startclient() ->
     spawn(udp_test, client, ["10.175.13.204", 53530, "Hello World from Erlang Client 1"]),
     spawn(udp_test, client, ["10.175.13.204", 53530, "Hello World from Erlang Client 2"]),
     spawn(udp_test, client, ["10.175.13.204", 53530, "Hello World from Erlang Client 3"]),
     spawn(udp_test, client, ["10.175.13.204", 53530, "Hello World from Erlang Client 4"]),
     spawn(udp_test, client, ["10.175.13.204", 53530, "Hello World from Erlang Client 5"]).
     % spawn(udp_test, client, ["10.175.13.204", 53530, "Hello World from Erlang Client 6"]),
     % spawn(udp_test, client, ["10.175.13.204", 53530, "Hello World from Erlang Client 7"]),
     % spawn(udp_test, client, ["10.175.13.204", 53530, "Hello World from Erlang Client 8"]),
     % spawn(udp_test, client, ["10.175.13.204", 53530, "Hello World from Erlang Client 9"]),
     % spawn(udp_test, client, ["10.175.13.204", 53530, "Hello World from Erlang Client 10"]),
     % spawn(udp_test, client, ["10.175.13.204", 53530, "Hello World from Erlang Client 11"]),
     % spawn(udp_test, client, ["10.175.13.204", 53530, "Hello World from Erlang Client 12"]),
     %spawn(udp_test, client, ["10.175.13.204", 53530, "Hello World from Erlang Client 13"]),
     %spawn(udp_test, client, ["10.175.13.204", 53530, "Hello World from Erlang Client 14"]).
