defmodule Untrusted.Verify do
  @moduledoc """
  This module holds functions that return booleans
  """
  defguard is_non_neg_integer(n) when is_integer(n) and n >= 0
  defguard is_positive_integer(n) when is_integer(n) and n >= 1
  defguard is_negative_integer(n) when is_integer(n) and n < 0

  defguard is_uint8(n) when n in 0..255
end
