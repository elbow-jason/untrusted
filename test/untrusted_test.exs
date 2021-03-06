defmodule UntrustedTest do
  use ExUnit.Case

  alias Untrusted.Error

  doctest Untrusted

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

  test "force keyword builds correctly" do
    assert [%Untrusted.Validation{forced?: true}] = Untrusted.build(Untrusted.TestExample, thing: [:force, :integer])
  end

  test "force validation forced a validation to run even if the key is not included" do
    error = %Error{source: nil, field: :thing, reason: :must_be_an_integer}
    assert {:error, [error]} == Untrusted.validate(Untrusted.TestExample, [thing: [:force, :integer]], %{})
  end

  test "validate/2 can handle lists when given non-list" do
    errors = [
      %Untrusted.Error{field: :items, reason: :must_be_a_list, source: 1}
    ]

    assert Untrusted.TestExample.int_list_item_tester(%{items: 1}) == {:error, errors}
  end

  test "validate/2 can handle lists when given invalid items" do
    errors = [
      %Untrusted.Error{field: :items, reason: :must_be_an_integer, source: :one}
    ]

    assert Untrusted.TestExample.int_list_item_tester(%{items: [:one]}) == {:error, errors}
  end

  test "validator returns {:ok, <value>} when item is valid" do
    assert Untrusted.TestExample.has_name(%{name: "Jason"}) == {:ok, %{name: "Jason"}}
  end

  test "validate/2 works on multiple fields" do
    assert Untrusted.TestExample.multiple_fields(%{age: 1}) ==
             {:error,
              [
                %Untrusted.Error{
                  field: :number,
                  reason: :key_is_required,
                  source: %{age: 1}
                },
                %Untrusted.Error{
                  field: :count,
                  reason: :key_is_required,
                  source: %{age: 1}
                }
              ]}
  end

  test "validate/2 errors for must_be_one_of lists" do
    import Untrusted.ValidatorFunctions, only: [must_be_one_of: 1]
    validator_params = [thing: must_be_one_of([1, 2, 3])]
    {:error, errors} = Untrusted.validate(Untrusted.TestExample, validator_params, %{thing: :not_one})

    assert errors == [
             %Untrusted.Error{field: :thing, reason: {:must_be_one_of, [1, 2, 3]}, source: :not_one}
           ]
  end

  test "validate/2 errors for must_be_one_of MapSets" do
    import Untrusted.ValidatorFunctions, only: [must_be_one_of: 1]
    set = MapSet.new([1, 2, 3])
    validator_params = [thing: must_be_one_of(set)]
    {:error, errors} = Untrusted.validate(Untrusted.TestExample, validator_params, %{thing: :not_one})

    assert errors == [
             %Untrusted.Error{field: :thing, reason: {:must_be_one_of, set}, source: :not_one}
           ]
  end

  test "validate/2 errors for must_be_key_of" do
    import Untrusted.ValidatorFunctions, only: [must_be_key_of: 1]

    mapping = %{
      "ONE" => 1,
      "TWO" => 2
    }

    keys = Map.keys(mapping)
    validator_params = [thing: must_be_key_of(mapping)]
    {:error, errors} = Untrusted.validate(Untrusted.TestExample, validator_params, %{thing: :not_one})

    assert errors == [
             %Untrusted.Error{field: :thing, reason: {:must_be_one_of, keys}, source: :not_one}
           ]
  end

  test "validate/2 works for must_be_nil" do
    result = Untrusted.validate(Untrusted.TestExample, [works: :must_be_nil], %{works: :maybe})
    error = %Untrusted.Error{field: :works, reason: :must_be_nil, source: :maybe}
    assert result == {:error, [error]}
  end

  test "validate/2 can handle stringy-keyed params map with atom-keyed validators" do
    result = Untrusted.validate(Untrusted.TestExample, [works: :must_be_nil], %{"works" => :maybe})
    error = %Untrusted.Error{field: :works, reason: :must_be_nil, source: :maybe}
    assert result == {:error, [error]}
  end

  test "build/2 works" do
    assert Untrusted.build(Untrusted.TestExample, works: :must_be_nil) == [
             %Untrusted.Validation{
               field: :works,
               functions: [{Untrusted.Validators, :must_be_nil, 1}],
               list?: false,
               required?: true,
               forced?: false
             }
           ]
  end

  describe "use Untrusted" do
    test "injects build" do
      result = Untrusted.TestExample.validate([works: :must_be_nil], %{works: :maybe})

      assert result ==
               {:error,
                [
                  %Untrusted.Error{
                    field: :works,
                    reason: :must_be_nil,
                    source: :maybe
                  }
                ]}
    end
  end
end
