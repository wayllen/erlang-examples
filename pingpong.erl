-module(pingpong).
-export([start/0, ping/1, pong/0]).
% Use register to regist PID for some process.
% Example of communication between processes.
ping(0) ->
     pong ! finished,
     io:format("ping finished.~n", []);
ping(N) ->
     pong ! {ping, self()},
     receive
          pong ->
               io:format("Ping received pong ~n",[])
     end,
     timer:sleep(500),
     ping(N-1).
pong() ->
     receive
          finished ->
               io:format("Pong finished.~n",[]);
          {ping, Ping_PID} ->
               io:format("Pong received ping. ~n",[]),
               Ping_PID ! pong,
               pong()
     end.
start() ->
     %Pong_PID=spawn(pingpong, pong,[]),
     register(pong,spawn(pingpong, pong,[])),
     spawn(pingpong, ping, [10]).
