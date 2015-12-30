%%%-------------------------------------------------------------------
%%% @author Paweł Banach, Wojciech Baczyński
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. gru 2015 12:52
%%%-------------------------------------------------------------------
-module(checker).
-include_lib("wx/include/wx.hrl").
-author("Wojciech Baczyński, Paweł Banach").

%% API
-compile(export_all).


%%Więc start generuje nam okienko a później idzie nam do pętli
%%tworzę funkcję send/0 która będzie naszym triggerem gdy przycisk send! jest jest wciśnięty
start() ->
  Window = wx:new(),  % Window will be the parent for the Frame
  State = wx:batch(fun() -> make_window(Window) end),     % wx:batch() - Improves performance of the command processing
  %% by grabbing the wxWidgets thread so that no event processing will be done before the complete batch of commands is invoked.
  %% !!! w tym miejscu należałoby puścić zegar współbieżnie!!!
  loop(State),
  wx:destroy(),
  ok.


%%--------------------------------------------------------------------------------------------
%%    GUI
%%--------------------------------------------------------------------------------------------
make_window(Window) ->
% new Frame
  Frame = wxFrame:new(Window, -1, "Tests checker", [{size,{480, 640}}]),  % wymiary okienka

  % ::INFO:: wxFrame:connect() - allows to catch an event, (it'll be used in loop(), where are event handlers)
  % catch an event - Standard closing window
  wxFrame:connect(Frame, close_window),

  % new Frame->Panel
    Panel = wxPanel:new(Frame), %window

    % create widgets
      T1001 = wxTextCtrl:new(Panel, 1001, [{size, {410, 140}}]),     % inputbox1 i jego wymiary
      T1002 = wxTextCtrl:new(Panel, 1002, [{size, {410, 140}}]),     % inputbox2 i jego wymiary
      T1003 = wxTextCtrl:new(Panel, 1003, [{size, {410, 140}}]),     % inputbox3 i jego wymiary
      ST2001 = wxStaticText:new(Panel, 2001,"Kliknij Start, aby zacząć!", []),

      B102  = wxButton:new(Panel, ?wxID_EXIT, [{label, "&Exit"}]),  % button Exit
      % ::INFO:: More about Standard IDs here: http://docs.wxwidgets.org/trunk/defs_8h.html#ac66d0a09761e7d86b2ac0b2e0c6a8cbb
      B101  = wxButton:new(Panel, 101, [{label, "&Start"}]),         % button Send

      % catch an event - Clicking buttons
      wxFrame:connect(Frame, command_button_clicked),

      %%You can create sizers before or after the widgets that will go into them, but
      %%the widgets have to exist before they are added to sizer.
        %%6 sizerów 3 sizery na nasze input boxy, 1 sizer na buttony, kolejny sizer->main na te 4 sizery, a to wszystko
        %%wsadzamy jeszcze do jednego sizera OuterSizer, po to żeby mieć margines
        OuterSizer = wxBoxSizer:new(?wxHORIZONTAL),
        MainSizer = wxBoxSizer:new(?wxVERTICAL),
        DownSizer = wxBoxSizer:new(?wxHORIZONTAL),
        InputSizer1 = wxStaticBoxSizer:new(?wxHORIZONTAL, Panel, [{label, "1. Jaki BIF tworzy nowy proces?"}]),
        InputSizer2 = wxStaticBoxSizer:new(?wxHORIZONTAL, Panel, [{label, "2. Jak wyczyścić skrzynkę odbiorczą?"}]),
        InputSizer3 = wxStaticBoxSizer:new(?wxHORIZONTAL, Panel, [{label, "3. Jak zmierzyć czas wykonania funkcji?"}]),

      %% Note that the widget is added using the VARIABLE, not the ID.
        %%Tutaj jest zabawa ze wsadzaniem buttonów/inputboxów w sizery i dodawanie marginesów
        wxSizer:add(InputSizer1, T1001, []),
        wxSizer:add(InputSizer2, T1002, []),
        wxSizer:add(InputSizer3, T1003, []),
        wxSizer:addSpacer(DownSizer, 5),  %spacer
        wxSizer:add(DownSizer, B101,   []),
        wxSizer:addSpacer(DownSizer, 20),  %spacer
        wxSizer:add(DownSizer, ST2001,   []),
        wxSizer:addSpacer(DownSizer, 95),  %spacer
        wxSizer:add(DownSizer, B102,   []),
        wxSizer:addSpacer(MainSizer, 20),  %spacer
        wxSizer:add(MainSizer, InputSizer1,   []),
        wxSizer:addSpacer(MainSizer, 15),  %spacer
        wxSizer:add(MainSizer, InputSizer2,   []),
        wxSizer:addSpacer(MainSizer, 15),  %spacer
        wxSizer:add(MainSizer, InputSizer3,   []),
        wxSizer:addSpacer(MainSizer, 15),  %spacer
        wxSizer:add(MainSizer, DownSizer,   []),

        wxSizer:addSpacer(OuterSizer, 20), % spacer
        wxSizer:add(OuterSizer, MainSizer, []),

    %% Now 'set' OuterSizer into the Panel
      wxPanel:setSizer(Panel, OuterSizer),
      wxFrame:show(Frame),
  {Frame, ST2001, T1001, T1002, T1003}. %% muszę zwrócić taką krotkę żeby miec dostęp do ST2001, T1001 itd.


%%--------------------------------------------------------------------------------------------
%%    WARSTWA LOGICZNA
%%--------------------------------------------------------------------------------------------
loop(State) ->
  {Frame, ST2001, T1001, T1002, T1003} = State,
  % ----------    EVENT HANDLERS    ----------
  % ::INFO:: more about handlers here: www.erlang.org/doc/man/wxEvtHandler.html

  %io:format("--waiting in the loop--~n", []), % optional, feedback to the shell
  receive
    % Standard closing window
    #wx{event=#wxClose{type=close_window}} ->
      io:format("~p Closing window ~n",[self()]),
      %now we use the reference to Frame
      wxWindow:destroy(Frame),  %closes the window
      ok;  % we exit the loop

    % Clicking Exit button
    #wx{id=?wxID_EXIT, event=#wxCommand{type=command_button_clicked}} ->
      io:format("~p Clicked button 'Exit' ~n",[self()]),
      io:format("~p Closing window ~n",[self()]),
      %now we use the reference to Frame
      wxWindow:destroy(Frame),  %closes the window
      ok;  % we exit the loop

    #wx{id=101, event=#wxCommand{type=command_button_clicked}} ->
      io:format("~p Clicked button 'Start' ~n",[self()]),
      cntdwn(1,0, ST2001), %na razie zrobiłem tak, że gdy przycisk Send wciśnięty to odlicza 1 min
      send(State),
      loop(State);

    % Another event (unhandled)
    Msg ->
      io:format("Got unhandled event! : ~n ~p ~n", [Msg]),
      loop(State)

  end.
%COUNT DOWN
cntdwn(0,0, StaticText) ->
  io:format("Koniec ~n"),
  OutputStr = "Koniec - odpowiedzi zostały wysłane!",
  wxStaticText:setLabel(StaticText, OutputStr),
  ok;

cntdwn(Min, 0, StaticText) ->
  %io:format("~w~w~n", [Min, 0]),
  Min_str = integer_to_list(Min),
  Sec_str = integer_to_list(0),
  OutputStr = lists:concat([["Do końca: ", Min_str, " min ", Sec_str, " sec"]]),
  wxStaticText:setLabel(StaticText, OutputStr),
  receive
  after 1000 ->
    true
  end,
  cntdwn(Min-1, 59, StaticText);

cntdwn(Min, Sec, StaticText) when Sec > 0 ->
  %io:format("~w~w~n", [Min, Sec]),
  Min_str = integer_to_list(Min),
  Sec_str = integer_to_list(Sec),
  OutputStr = lists:concat([["Do końca: ", Min_str, " min ", Sec_str, " sec"]]),
  wxStaticText:setLabel(StaticText, OutputStr),
  receive
  after 1000 ->
    true
  end,
  cntdwn(Min, Sec-1, StaticText);

cntdwn(_,_,StaticText) ->
  io:format("Error"),
  OutputStr = "An error has occured!",
  wxStaticText:setLabel(StaticText, OutputStr),
  ok.

send(State) ->
  {_, _, T1001, T1002, T1003} = State,
  T1001_str = wxTextCtrl:getValue(T1001), %tekst mamy co z nim robimy?
  T1002_str = wxTextCtrl:getValue(T1002),
  T1003_str = wxTextCtrl:getValue(T1003),
  Answer = lists:concat([["\n Zadanie 1 \n", T1001_str,"\n Zadanie 2 \n", T1002_str,"\n Zadanie 3 \n", T1003_str]]),
  io:format(Answer),
ok. %zbiera wpisany tekst ze wszystkich trzech okienek a później go wysyła na meila
