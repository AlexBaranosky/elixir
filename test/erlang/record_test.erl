-module(record_test).
-include_lib("eunit/include/eunit.hrl").

record_reader_test() ->
  F = fun() ->
    elixir:eval("defrecord Foo, a: 1, b: 2, c: 3"),
    { 1, _ } = elixir:eval("{ Foo, 1, 2, 3 }.a"),
    { 2, _ } = elixir:eval("{ Foo, 1, 2, 3 }.b"),
    { 3, _ } = elixir:eval("{ Foo, 1, 2, 3 }.c")
  end,
  test_helper:run_and_remove(F, ['::Foo']).

record_setter_test() ->
  F = fun() ->
    elixir:eval("defrecord Foo, a: 1, b: 2, c: 3"),
    { { '::Foo', 10, 2, 3 }, _ } = elixir:eval("{ Foo, 1, 2, 3 }.a(10)")
  end,
  test_helper:run_and_remove(F, ['::Foo']).

record_new_defaults_test() ->
  F = fun() ->
    elixir:eval("defrecord Foo, a: 1, b: 2, c: 3"),
    { { '::Foo', 1, 2, 3 }, _ } = elixir:eval("Foo.new"),
    { 1, _ } = elixir:eval("Foo.new.a")
  end,
  test_helper:run_and_remove(F, ['::Foo']).

record_new_selective_test() ->
  F = fun() ->
    elixir:eval("defrecord Foo, a: 1, b: 2, c: 3"),
    { { '::Foo', 1, 20, 3 }, _ } = elixir:eval("Foo.new b: 20"),
    { 20, _ } = elixir:eval("Foo.new(b: 20).b")
  end,
  test_helper:run_and_remove(F, ['::Foo']).

record_append_prepend_test() ->
  F = fun() ->
    elixir:eval("defrecord Foo, a: 1, b: [3], c: 3"),
    { { '::Foo', 1, [3,4,5], 3 }, _ } = elixir:eval("Foo.new.append_b  [4,5]"),
    { { '::Foo', 1, [1,2,3], 3 }, _ } = elixir:eval("Foo.new.prepend_b [1,2]")
  end,
  test_helper:run_and_remove(F, ['::Foo']).

record_merge_test() ->
  F = fun() ->
    elixir:eval("defrecord Foo, a: [foo: :bar]"),
    { { '::Foo', [{a,1},{foo,baz}] }, _ } = elixir:eval("Foo.new.merge_a  [foo: :baz, a: 1]")
  end,
  test_helper:run_and_remove(F, ['::Foo']).

record_increment_test() ->
  F = fun() ->
    elixir:eval("defrecord Foo, a: 0"),
    { { '::Foo', 1 }, _ } = elixir:eval("Foo.new.increment_a"),
    { { '::Foo', 10 }, _ } = elixir:eval("Foo.new.increment_a 10"),
    { { '::Foo', -2 }, _ } = elixir:eval("Foo.new.increment_a -2")
  end,
  test_helper:run_and_remove(F, ['::Foo']).

nested_record_test() ->
  F = fun() ->
    elixir:eval("defmodule Foo, do: defrecord(Bar, a: 1, b: 2, c: 3)"),
    { { '::Foo::Bar', 1, 2, 3 }, _ } = elixir:eval("Foo::Bar.new"),
    { 1, _ } = elixir:eval("Foo::Bar.new.a")
  end,
  test_helper:run_and_remove(F, ['::Foo', '::Foo::Bar']).

nested_record_refer_test() ->
  F = fun() ->
    elixir:eval("defmodule Foo do\ndefrecord(Bar, a: 1)\ndef bar, do: Bar.new\nend"),
    { { '::Foo::Bar', 1 }, _ } = elixir:eval("Foo.bar")
  end,
  test_helper:run_and_remove(F, ['::Foo', '::Foo::Bar']).

nested_record_no_refer_test() ->
  F = fun() ->
    elixir:eval("defmodule Foo do\ndefrecord(Bar, [a: 1], as: false)\ndef bar, do: Bar.new\nend"),
    ?assertError(undef, elixir:eval("Foo.bar"))
  end,
  test_helper:run_and_remove(F, ['::Foo', '::Foo::Bar']).

nested_record_custom_refer_test() ->
  F = fun() ->
    elixir:eval("defmodule Foo do\ndefrecord(Bar, [a: 1], as: Baz)\ndef bar, do: Baz.new\nend"),
    { { '::Foo::Bar', 1 }, _ } = elixir:eval("Foo.bar")
  end,
  test_helper:run_and_remove(F, ['::Foo', '::Foo::Bar']).