%%%-------------------------------------------------------------------
%%% @author Paweł
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. gru 2015 12:52
%%%-------------------------------------------------------------------
-module(checker).
-compile(export_all).
-include_lib("wx/include/wx.hrl").

%%Więc start generuje nam okienko a później idzie nam do pętli
%%tworzę funkcję send/0 która będzie naszym triggerem gdy przycisk send! jest jest wciśnięty
start() ->
  State = make_window(),
  loop (State).
%%--------------------------------------------------------------------------------------------
%%GUI
%%--------------------------------------------------------------------------------------------
make_window() ->
  Server = wx:new(),  %Server will be the parent for the Frame
  Frame = wxFrame:new( Server, -1, "Tests checker", [{size,{480, 640}}]),%wymiary okienka
  Panel = wxPanel:new(Frame), %window

%% create widgets
  T1001 = wxTextCtrl:new(Panel, 1001,[{size, {410, 140}}]), %inputbox1 i jego wymiary
  T1002 = wxTextCtrl:new(Panel, 1001,[{size, {410, 140}}]), %inputbox2 i jego wymiary
  T1003 = wxTextCtrl:new(Panel, 1001,[{size, {410, 140}}]), %inputbox3 i jego wymiary
  %%ST2001 = wxStaticText:new(Panel, 2001,"Output Area", []), jakiś output może się później przydać
  B102  = wxButton:new(Panel, ?wxID_EXIT, [{label, "E&xit"}]), %button Exit
  B101  = wxButton:new(Panel, 101, [{label, "&Send"}]),         %button Send

%%You can create sizers before or after the widgets that will go into them, but
%%the widgets have to exist before they are added to sizer.
  %%6 sizerów 3 sizery na nasze input boxy, 1 sizer na buttony, kolejny sizer->main na te 4 sizery, a to wszystko
  %%wsadzamy jeszcze do jednego sizera OuterSizer, po to żeby mieć margines
  OuterSizer   = wxBoxSizer:new(?wxHORIZONTAL),
  MainSizer = wxBoxSizer:new(?wxVERTICAL),
  DownSizer = wxBoxSizer:new(?wxHORIZONTAL),
  InputSizer1 = wxStaticBoxSizer:new(?wxHORIZONTAL, Panel, [{label, " Jaki BIF tworzy nowy proces i jakie argumenty przyjmuje?"}]),
  InputSizer2 = wxStaticBoxSizer:new(?wxHORIZONTAL, Panel, [{label, "Jak wyczyścić skrzynkę odbiorczą?"}]),
  InputSizer3 = wxStaticBoxSizer:new(?wxHORIZONTAL, Panel, [{label, "Jak zmierzyć czas wykonania funkcji?"}]),


%% Note that the widget is added using the VARIABLE, not the ID.
  %%Tutaj jest zabawa ze wsadzaniem buttonów/inputboxów w sizery i dodawanie marginesów
  wxSizer:add(InputSizer1, T1001,  []),
  wxSizer:add(InputSizer2, T1002, []),
  wxSizer:add(InputSizer3, T1003,   []),
  wxSizer:addSpacer(DownSizer, 5),  %spacer
  wxSizer:add(DownSizer, B101,   []),
  wxSizer:addSpacer(DownSizer, 235),  %spacer
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
  ok.  %the return value will go here, soon
%%--------------------------------------------------------------------------------------------
%%WARSTWA LOGICZNA
%%--------------------------------------------------------------------------------------------
loop(State) ->  State, %stub
  ok.

send() -> ok. %zbiera wpisany tekst ze wszystkich trzech okienek a później go wysyła na meila
