defmodule UntrustedTest do
  use ExUnit.Case
  doctest Untrusted

  alias Untrusted.Validation

  test "__untrusted__(:namespaces) lists configured namespaces" do
    assert Untrusted.TestExample.__untrusted__(:namespaces) == [Untrusted.TestExample.Validators, Untrusted.Validators]
  end


  test "modules with a validate/1 can be used as a validator" do
    errors = [
      %Untrusted.Error{field: :is_other?, reason: :must_be_a_boolean, source: "not_a_boolean"}
    ]
    assert Untrusted.TestExample.module_tester(%{other: %{is_other?: "not_a_boolean"}}) == {:error, errors}
  end

  test "returns key is required for as reason for missing keys" do
    errors = [
      %Untrusted.Error{
        field: :name,
        reason: :key_is_required,
        source: %{item: 1}
      }
    ]
    assert Untrusted.TestExample.has_name(%{item: 1}) == {:error, errors}
  end

  test "validate/2 can handle lists when given non-list" do
    errors = [
      %Untrusted.Error{field: :items, reason: :must_be_a_list, source: 1}
    ]
    assert Untrusted.TestExample.int_list_item_tester(%{items: 1}) == {:error, errors}
  end

  test "validate/2 can handle lists when given invalid items" do
    errors = [
      %Untrusted.Error{field: :items, reason:  :must_be_an_integer, source: :one},
    ]
    assert Untrusted.TestExample.int_list_item_tester(%{items: [:one]}) == {:error, errors}
  end

  test "validate/2 returns :ok when item is valid" do
    assert Untrusted.TestExample.has_name(%{name: "Jason"}) == :ok
  end

end
