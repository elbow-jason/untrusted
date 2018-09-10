defmodule Untrusted.VerifierTest do
  use ExUnit.Case
  require Untrusted.Verify
  alias Untrusted.Verify

  test "is_non_neg_integer/1 works" do
    assert Verify.is_non_neg_integer(1) == true
    assert Verify.is_non_neg_integer(0) == true
    assert Verify.is_non_neg_integer(-1) == false
  end

  test "is_positive_integer/1 works" do
    assert Verify.is_positive_integer(1) == true
    assert Verify.is_positive_integer(0) == false
    assert Verify.is_positive_integer(-1) == false
  end

  test "is_negative_integer/1 works" do
    assert Verify.is_negative_integer(1) == false
    assert Verify.is_negative_integer(0) == false
    assert Verify.is_negative_integer(-1) == true
  end

  test "is_uint8/1 works" do
    assert Verify.is_uint8(-1) == false
    assert Verify.is_uint8(0) == true
    assert Verify.is_uint8(255) == true
    assert Verify.is_uint8(256) == false
  end
end
