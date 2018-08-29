defmodule Untrusted.Validators do
  require Untrusted.Verify

  alias Untrusted.Verify

  def non_neg_integer(x) when Verify.is_non_neg_integer(x), do: :ok
  def non_neg_integer(_), do: {:error, :must_be_a_non_negative_integer}

  def positive_integer(x) when Verify.is_positive_integer(x), do: :ok
  def positive_integer(_), do: {:error, :must_be_a_positive_integer}

  def negative_integer(x) when Verify.is_negative_integer(x), do: :ok
  def negative_integer(_), do: {:error, :must_be_a_negative_integer}

  def uint8(x) when Verify.is_uint8(x), do: :ok
  def uint8(_), do: {:error, :must_be_a_uint8}

  def string(x) when is_binary(x), do: :ok
  def string(_), do: {:error, :must_be_a_string}

  def integer(x) when is_integer(x), do: :ok
  def integer(_), do: {:error, :must_be_an_integer}

  def float(x) when is_float(x), do: :ok
  def float(_), do: {:error, :must_be_a_float}

  def boolean(x) when is_boolean(x), do: :ok
  def boolean(_), do: {:error, :must_be_a_boolean}

end
