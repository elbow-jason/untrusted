defmodule Untrusted.ResolverTest do
  use ExUnit.Case

  describe "unalias/1" do
    test "returns no alias when no env is supplied" do
      assert Untrusted.Resolver.unalias(:bleep) == :bleep
    end
  end

  describe "unalias/2" do
    test "returns an alias given a Macro.Env struct" do
      env = %Macro.Env{aliases: [{:bleep, :blop}]}
      assert Untrusted.Resolver.unalias(:bleep, env) == :blop
    end

    test "returns exactly the given module when the Macro.Env struct has no alias for the given module" do
      env = %Macro.Env{aliases: [{:flim, :flam}]}
      assert Untrusted.Resolver.unalias(:bleep, env) == :bleep
    end
  end

  describe "resolve_module_function!/3" do
    test "finds the function of an arbitrary module" do
      assert Untrusted.Resolver.resolve_module_function!(URI, :parse, 1) == {URI, :parse, 1}
    end

    test "raises when it does not find a function" do
      assert_raise(CompileError, fn ->
        Untrusted.Resolver.resolve_module_function!(URI, :bleep, 1)
      end)
    end
  end

  describe "resolve_module_function/3" do
    test "returns ok-tuple when it finds the function of an arbitrary module" do
      assert Untrusted.Resolver.resolve_module_function(URI, :parse, 1) == {:ok, URI, :parse, 1}
    end

    test "raises when it does not find a function" do
      assert Untrusted.Resolver.resolve_module_function(URI, :bleep, 1) == {:error, :no_such_function}
    end
  end
end
