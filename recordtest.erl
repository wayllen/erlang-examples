-module(recordtest).
%%-record(message,{client_pid, name, phone, address}).
%% Be careful!!! query is reserved word for Erlang. I have spent 2 hours on dealing with the error.

-record(mquery,{client_pid, name, phone, address}).
-record(mupdate,{client_pid, name, phone, address}).
-record(mdelete,{client_pid, name, phone, address}).
-record(madd,{client_pid, name, phone, address}).
-record(msg,{name,phone,address}).
-export([phonebook/1, start/0]).

%% A very simple phone book app.
%% To understand the programming principle of Erlang.
%% Data is always on fly.
%% Rui Xie
%% Date: 2012-06-13


phonebook(User_List) ->
  receive
                { myquery, From, Msg} ->
                        io:format("my query ~p,~p,~p,~p~n",[From,Msg#msg.name, Msg#msg.phone,Msg#msg.address]),
                        phonebook(User_List);
                { myupdate, From, Msg} ->
                        io:format("myupdate ~p,~p,~p,~p~n",[From,Msg#msg.name, Msg#msg.phone,Msg#msg.address]),
                        New_User_List=phonebook_update(From, Msg, User_List),
                        phonebook(New_User_List);
                { myadd, From, Msg} ->
                        io:format("myadd ~p,~p,~p,~p~n",[From,Msg#msg.name, Msg#msg.phone,Msg#msg.address]),
                        New_User_List=phonebook_add(From, Msg, User_List),
                        phonebook(New_User_List);
                { mydelete, From, Msg} ->
                        io:format("mydelete ~p,~p,~p,~p~n",[From,Msg#msg.name, Msg#msg.phone,Msg#msg.address]),
                        New_User_List=phonebook_delete(From, Msg, User_List),
                        phonebook(New_User_List);
                _ ->
                        io:format("Error"),
                        phonebook(User_List)
	end.
    
phonebook_query(From, User, User_List) ->
        case lists:keysearch(User#msg.name, #msg.name, User_List) of
		false ->
			From ! {fail, "User not found.~n"},
			User_List;
                {value, Person} ->
                        io:format("phonebook_query:~p,~p,~p~n",[Person#msg.name, Person#msg.phone,Person#msg.address]),
                        User_List
			%io:format("~p,~p,~p~n",[Name,Phone,Address])

	end.
    
phonebook_add(From, User, User_List) ->
	case lists:keymember(User#msg.name, #msg.name, User_List) of
		false ->
			From ! {success},
			[ User | User_List];
		true ->
			From ! {fail, "Duplicate Entry"},
			User_List
	end.
			
phonebook_update(From, User, User_List) ->
	case lists:keysearch(User#msg.name, #msg.name, User_List) of
		false ->
			From ! {fail, "User not found.~n"},
			User_List;
		{value, Person} ->
			io:format("hello")
	end.

phonebook_delete(From, User, User_List) ->
	case lists:keysearch(User#msg.name, #msg.name, User_List) of
		false ->
			%From ! {fail, "User not found."},

                        io:format("User not found~n"),
			User_List;
		{value, Person} ->
			io:format("mydelete ~p,~p,~p~n",[Person#msg.name,Person#msg.phone,Person#msg.address]),
                        New_User_List=lists:delete(Person,User_List),
                        New_User_List
	end.

start() ->
        M1=#msg{name="ruix",phone="123",address="wangjing"},
        M2=#msg{name="yan",phone="234",address="wangjing"},
        M3=#msg{name="qingze",phone="456",address="chaoyang"},
        PID=spawn(test3,phonebook,[[]]),
        PID!{myadd,self(),M1},
        PID!{myadd,self(),M2},
        PID!{mydelete,self(),M1},
        PID!{myquery,self(),M3},
        PID!{mydelete,self(),M3}.
