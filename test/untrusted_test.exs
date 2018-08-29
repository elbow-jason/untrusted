defmodule UntrustedTest do
  use ExUnit.Case
  doctest Untrusted

  alias Untrusted.Validation

  test "__untrusted__(:namespaces) lists configured namespaces" do
    assert Untrusted.TestExample.__untrusted__(:namespaces) == [Untrusted.TestExample.Validators, Untrusted.Validators]
  end

  test "__untrusted__(:validators) is a map of lists" do
    result = Untrusted.TestExample.__untrusted__(:validators)
    assert is_map(result)
    Enum.each(result, fn {_, validators} ->
      assert is_list(validators)
      Enum.each(validators, fn val ->
        assert match?(%Validation{}, val)
      end)
    end)
  end

  test "validator/1 injects the function validate/1" do
    Code.ensure_loaded?(Untrusted.TestExample)
    assert function_exported?(Untrusted.TestExample, :validate, 1)
  end

  test "validator/2 injects the function validate/2" do
    Code.ensure_loaded?(Untrusted.TestExample)
    assert function_exported?(Untrusted.TestExample, :validate, 2)
  end

  test "modules with a validate/1 can be used as a validator" do
    assert Untrusted.TestExample.validate(:module_tester, %{other: %{count: "should_be_uint"}}) == [
      %Untrusted.Error{field: :count, reason: :must_be_a_non_negative_integer, source: "should_be_uint"}
    ]
  end

  test "validate/1 runs validations" do
    assert Untrusted.TestExample.validate(%{item: 1}) == [
      %Untrusted.Error{
        field: :name,
        reason: :key_is_required,
        source: %{item: 1}
      }
    ]
  end
  test "validate/2 runs validations" do
    assert Untrusted.TestExample.validate(:named_validator, %{item: 1}) == [
      %Untrusted.Error{reason: :key_is_required, source: %{item: 1}, field: :count},
    ]
  end

  test "validate/2 can handle lists when given non-list" do
    assert Untrusted.TestExample.validate(:list_tester, %{items: 1}) == [
      %Untrusted.Error{field: :items, reason: :must_be_a_list, source: 1}
    ]
  end

  test "validate/2 can handle lists when given invalid items" do
    assert Untrusted.TestExample.validate(:list_tester, %{items: [:one]}) == [
      %Untrusted.Error{field: :items, reason:  :must_be_an_integer, source: :one}
    ]
  end

end
