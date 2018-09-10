defmodule Untrusted.Validators do
  require Untrusted.Verify

  alias Untrusted.Verify

  @spec non_neg_integer(any()) :: :ok | {:error, :must_be_a_non_negative_integer}
  def non_neg_integer(x) when Verify.is_non_neg_integer(x), do: :ok
  def non_neg_integer(_), do: {:error, :must_be_a_non_negative_integer}

  @spec positive_integer(any()) :: :ok | {:error, :must_be_a_positive_integer}
  def positive_integer(x) when Verify.is_positive_integer(x), do: :ok
  def positive_integer(_), do: {:error, :must_be_a_positive_integer}

  @spec negative_integer(any()) :: :ok | {:error, :must_be_a_negative_integer}
  def negative_integer(x) when Verify.is_negative_integer(x), do: :ok
  def negative_integer(_), do: {:error, :must_be_a_negative_integer}

  @spec uint8(any()) :: :ok | {:error, :must_be_a_uint8}
  def uint8(x) when Verify.is_uint8(x), do: :ok
  def uint8(_), do: {:error, :must_be_a_uint8}

  @spec string(any()) :: :ok | {:error, :must_be_a_string}
  def string(x) when is_binary(x), do: :ok
  def string(_), do: {:error, :must_be_a_string}

  @spec integer(any()) :: :ok | {:error, :must_be_an_integer}
  def integer(x) when is_integer(x), do: :ok
  def integer(_), do: {:error, :must_be_an_integer}

  @spec float(any()) :: :ok | {:error, :must_be_a_float}
  def float(x) when is_float(x), do: :ok
  def float(_), do: {:error, :must_be_a_float}

  @spec boolean(any()) :: :ok | {:error, :must_be_a_boolean}
  def boolean(x) when is_boolean(x), do: :ok
  def boolean(_), do: {:error, :must_be_a_boolean}

  @spec must_be_nil(any()) :: :ok | {:error, :must_be_nil}
  def must_be_nil(nil), do: :ok
  def must_be_nil(_), do: {:error, :must_be_nil}
end
