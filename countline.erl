-module(countline).
-export([countlines/1]).

int_countlines(Device, Result) ->
    case io:get_line(Device, "") of
        eof  -> file:close(Device), Result;
        Line -> int_countlines(Device, Result + 1)
    end.
    
countlines(FileName) ->
    {ok, Device} = file:open(FileName,[read]),
    int_countlines(Device, 0).