defmodule ProtocolTest do
  use ExUnit::Case

  defmodule __MODULE__ :: WithAll do
    defprotocol [blank(thing)]
  end

  defmodule __MODULE__ :: WithExcept do
    defprotocol [blank(thing)], except: [Atom, Number, List]
  end

  defmodule __MODULE__ :: WithOnly do
    defprotocol [blank(thing)], only: [Tuple, Function]
  end

  defrecord Foo, a: 0, b: 0

  defimpl __MODULE__ :: WithAll, for: Foo do
    def blank(record) do
      record.a + record.b == 0
    end
  end

  def test_protocol_with_all do
    assert_undef(ProtocolTest::WithAll, Atom, :foo)
    assert_undef(ProtocolTest::WithAll, Function, fn(x, do: x))
    assert_undef(ProtocolTest::WithAll, Number, 1)
    assert_undef(ProtocolTest::WithAll, Number, 1.1)
    assert_undef(ProtocolTest::WithAll, List, [])
    assert_undef(ProtocolTest::WithAll, List, [1,2,3])
    assert_undef(ProtocolTest::WithAll, Tuple, {})
    assert_undef(ProtocolTest::WithAll, Tuple, {1,2,3})
    assert_undef(ProtocolTest::WithAll, Tuple, {Bar,2,3})
    assert_undef(ProtocolTest::WithAll, BitString, "foo")
    assert_undef(ProtocolTest::WithAll, BitString, bitstr(1))
    assert_undef(ProtocolTest::WithAll, PID, self())
    assert_undef(ProtocolTest::WithAll, Port, hd(:erlang.ports))
    assert_undef(ProtocolTest::WithAll, Reference, make_ref)
  end

  def test_protocol_with_except do
    assert_undef(ProtocolTest::WithExcept, Any, :foo)
    assert_undef(ProtocolTest::WithExcept, Any, 1)
    assert_undef(ProtocolTest::WithExcept, Any, [1,2,3])
    assert_undef(ProtocolTest::WithExcept, Function, fn(x, do: x))
    assert_undef(ProtocolTest::WithExcept, Tuple, {})
  end

  def test_protocol_with_only do
    assert_undef(ProtocolTest::WithOnly, Any, :foo)
    assert_undef(ProtocolTest::WithOnly, Any, 1)
    assert_undef(ProtocolTest::WithOnly, Any, [1,2,3])
    assert_undef(ProtocolTest::WithOnly, Function, fn(x, do: x))
    assert_undef(ProtocolTest::WithOnly, Tuple, {})
  end

  def test_protocol_with_record do
    true  = ProtocolTest::WithAll.blank(ProtocolTest::Foo.new)
    false = ProtocolTest::WithAll.blank(ProtocolTest::Foo.new(a: 1))
  end

  # Dispatch `blank(thing)` to the given `target`
  # and check if it will dispatch (and successfully fail)
  # to the proper implementation `impl`.
  defp assert_undef(target, impl, thing) do
    try do
      target.blank(thing)
      error("Expected invocation to fail")
    catch: { :error, :undef, [stack|_] }
      ref = target :: impl
      case hd(stack) do
      match: { ^ref, :blank, [^thing] }
        :ok
      match: { ^ref, :blank, [^thing], []}
        :ok
      else:
        error("Invalid stack #{stack}. Expected: { #{ref}, :blank, [#{thing}] }")
      end
    end
  end
end