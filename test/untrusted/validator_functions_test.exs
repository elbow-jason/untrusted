defmodule Untrusted.ValidatorFunctionsTest do
  use ExUnit.Case

  describe "must_be_one_of/1" do
    test "returns a function of arity 1" do
      func = Untrusted.ValidatorFunctions.must_be_one_of([1, 2, 3])
      assert is_function(func, 1)
    end

    test "func returns an ok-value-tuple when value is in the list" do
      item = 1
      items = [1, 2, 3]
      func = Untrusted.ValidatorFunctions.must_be_one_of(items)
      assert item in items
      assert func.(item) == {:ok, item}
    end

    test "func returns an error when value is not in the list" do
      item = :no
      items = [1, 2, 3]
      func = Untrusted.ValidatorFunctions.must_be_one_of(items)
      assert item not in items
      assert func.(item) == {:error, {:must_be_one_of, items}}
    end

    test "can handle a MapSet" do
      set = MapSet.new([1, 2, 3])
      func = Untrusted.ValidatorFunctions.must_be_one_of(set)
      assert is_function(func, 1)
      assert 1 in set
      assert func.(1) == {:ok, 1}
    end
  end

  describe "must_be_key_of/1" do
    test "returns a function of arity 1" do
      mapping = %{
        "ONE" => 1,
        "TWO" => 2
      }

      func = Untrusted.ValidatorFunctions.must_be_key_of(mapping)
      assert is_function(func, 1)
    end

    test "func returns an ok-value-tuple when value is in the keys of the map" do
      mapping = %{
        "ONE" => 1,
        "TWO" => 2
      }

      func = Untrusted.ValidatorFunctions.must_be_key_of(mapping)
      assert Map.get(mapping, "ONE") == 1
      assert func.("ONE") == {:ok, 1}
    end
  end
end
