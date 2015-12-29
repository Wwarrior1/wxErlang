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
  Frame = wx:batch(fun() -> make_window(Window) end),     % wx:batch() - Improves performance of the command processing by grabbing the wxWidgets thread so that no event processing will be done before the complete batch of commands is invoked.
  wxWindow:show(Frame),
  loop(Frame),
  wx:destroy(),       % gdy opuscimy petle - zakoncz program
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
      Inputbox1 = wxTextCtrl:new(Panel, 1001, [{size, {410, 140}}]),     % inputbox1 i jego wymiary
      Inputbox2 = wxTextCtrl:new(Panel, 1002, [{size, {410, 140}}]),     % inputbox2 i jego wymiary
      Inputbox3 = wxTextCtrl:new(Panel, 1003, [{size, {410, 140}}]),     % inputbox3 i jego wymiary
      ST2001 = wxStaticText:new(Panel, 2001,"Do końca: 10 min 0 sek", []),

      B102  = wxButton:new(Panel, ?wxID_EXIT, [{label, "&Exit"}]),  % button Exit
      % ::INFO:: More about Standard IDs here: http://docs.wxwidgets.org/trunk/defs_8h.html#ac66d0a09761e7d86b2ac0b2e0c6a8cbb
      B101  = wxButton:new(Panel, 101, [{label, "&Send"}]),         % button Send

      % catch an event - Clicking buttons
      wxFrame:connect(Frame, command_button_clicked),

      %%You can create sizers before or after the widgets that will go into them, but
      %%the widgets have to exist before they are added to sizer.
        %%6 sizerów 3 sizery na nasze input boxy, 1 sizer na buttony, kolejny sizer->main na te 4 sizery, a to wszystko
        %%wsadzamy jeszcze do jednego sizera OuterSizer, po to żeby mieć margines
        OuterSizer = wxBoxSizer:new(?wxHORIZONTAL),
        MainSizer = wxBoxSizer:new(?wxVERTICAL),
        DownSizer = wxBoxSizer:new(?wxHORIZONTAL),
        InputSizer1 = wxStaticBoxSizer:new(?wxHORIZONTAL, Panel, [{label, "Jaki BIF tworzy nowy proces i jakie argumenty przyjmuje?"}]),
        InputSizer2 = wxStaticBoxSizer:new(?wxHORIZONTAL, Panel, [{label, "Jak wyczyścić skrzynkę odbiorczą?"}]),
        InputSizer3 = wxStaticBoxSizer:new(?wxHORIZONTAL, Panel, [{label, "Jak zmierzyć czas wykonania funkcji?"}]),

      %% Note that the widget is added using the VARIABLE, not the ID.
        %%Tutaj jest zabawa ze wsadzaniem buttonów/inputboxów w sizery i dodawanie marginesów
        wxSizer:add(InputSizer1, Inputbox1, []),
        wxSizer:add(InputSizer2, Inputbox2, []),
        wxSizer:add(InputSizer3, Inputbox3, []),
        wxSizer:addSpacer(DownSizer, 5),  %spacer
        wxSizer:add(DownSizer, B101,   []),
        wxSizer:addSpacer(DownSizer, 50),  %spacer
        wxSizer:add(DownSizer, ST2001,   []),
        wxSizer:addSpacer(DownSizer, 65),  %spacer
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

  Frame.


%%--------------------------------------------------------------------------------------------
%%    WARSTWA LOGICZNA
%%--------------------------------------------------------------------------------------------
loop(Frame) ->
  % ----------    EVENT HANDLERS    ----------
  % ::INFO:: more about handlers here: www.erlang.org/doc/man/wxEvtHandler.html
  io:format("--waiting in the loop--~n", []), % optional, feedback to the shell
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
      io:format("~p Clicked button 'Send' ~n",[self()]),
      loop(Frame);

    % Another event (unhandled)
    Msg ->
      io:format("Got unhandled event! : ~n ~p ~n", [Msg]),
      loop(Frame)
  end.

send() -> ok. %zbiera wpisany tekst ze wszystkich trzech okienek a później go wysyła na meila
