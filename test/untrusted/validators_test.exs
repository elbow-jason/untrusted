defmodule Untrusted.ValidatorTest do
  use ExUnit.Case

  alias Untrusted.Validators

  test "is_non_neg_integer/1 works" do
    assert Validators.non_neg_integer(1) == :ok
    assert Validators.non_neg_integer(0) == :ok
    assert Validators.non_neg_integer(-1) == {:error, :must_be_a_non_negative_integer}
  end

  test "is_positive_integer/1 works" do
    assert Validators.positive_integer(1) == :ok
    assert Validators.positive_integer(0) == {:error, :must_be_a_positive_integer}
    assert Validators.positive_integer(-1) == {:error, :must_be_a_positive_integer}
  end

  test "is_negative_integer/1 works" do
    assert Validators.negative_integer(-1) == :ok
    assert Validators.negative_integer(1) == {:error, :must_be_a_negative_integer}
    assert Validators.negative_integer(0) == {:error, :must_be_a_negative_integer}
  end

  test "is_uint8/1 works" do
    assert Validators.uint8(-1) == {:error, :must_be_a_uint8}
    for n <- 0..255 do
      assert Validators.uint8(n) == :ok
    end
    assert Validators.uint8(256) == {:error, :must_be_a_uint8}
  end

end
