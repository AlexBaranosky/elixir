defmodule Elixir::FormatterTest do
  use ExUnit::Case

  defmodule __MODULE__ :: Foo do
     def bar, do: nil
  end

  import Elixir::Formatter, only: [format_stacktrace: 1, format_catch: 2]

  def test_format_stacktrace_earlier_erlang_releases do
    "::Foo.bar()" = format_stacktrace({::Foo, :bar, []})
    "::Foo.bar(1, 2, 3)" = format_stacktrace({::Foo, :bar, [1, 2, 3]})
    "::Foo.bar/1" = format_stacktrace({::Foo, :bar, 1})
  end

  def test_format_stacktrace_earlier_erlang_r15_release_with_no_file_or_line do
    "::Foo.bar(1, 2, 3)" = format_stacktrace({::Foo, :bar, [1, 2, 3], []})
    "::Foo.bar()" = format_stacktrace({::Foo, :bar, [], []})
    "::Foo.bar/1" = format_stacktrace({::Foo, :bar, 1, []})
  end

  def test_format_stacktrace_earlier_erlang_r15_release_with_file_and_line do
    "file.ex:10: ::Foo.bar()" = format_stacktrace({::Foo, :bar, [], [file: 'file.ex', line: 10]})
    "file.ex:10: ::Foo.bar(1, 2, 3)" = format_stacktrace({::Foo, :bar, [1, 2, 3], [file: 'file.ex', line: 10]})
    "file.ex:10: ::Foo.bar/1" = format_stacktrace({::Foo, :bar, 1, [file: 'file.ex', line: 10]})
  end

  def test_format_stacktrace_earlier_erlang_r15_release_with_file_no_line do
    "file.ex: ::Foo.bar()" = format_stacktrace({::Foo, :bar, [], [file: 'file.ex']})
    "file.ex: ::Foo.bar(1, 2, 3)" = format_stacktrace({::Foo, :bar, [1, 2, 3], [file: 'file.ex']})
    "file.ex: ::Foo.bar/1" = format_stacktrace({::Foo, :bar, 1, [file: 'file.ex']})
  end

  def test_format_catch do
    "nofile:10: invalid token: :\#" = format_catch(:error, {:badsyntax, {10, 'nofile', 'invalid token: ', ':#'}})
    "nofile:1: function a/0 undefined" = format_catch(:error, {:badform, { 1, 'nofile', :erl_lint, {:undefined_function,{:a,0}} } })
  end
end
