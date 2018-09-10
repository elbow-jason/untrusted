defmodule Untrusted.ValidatorFunctions do
  @type must_be_one_of_error :: {:error, {:must_be_one_of, list(any())}}

  @type collection :: list(any) | MapSet.t()

  @spec must_be_one_of(collection()) :: (any() ->  must_be_one_of_error() | {:ok, any()})
  def must_be_one_of(items) when is_list(items) do
    do_must_be_one_of(items)
  end

  def must_be_one_of(%MapSet{} = items) do
    do_must_be_one_of(items)
  end

  defp do_must_be_one_of(items) do
    fn (value) ->
      if value in items do
        {:ok, value}
      else
        {:error, {:must_be_one_of, items}}
      end
    end
  end

  @spec must_be_key_of(map()) :: (any() -> must_be_one_of_error() | {:ok, any()})
  def must_be_key_of(mapping) when is_map(mapping) do
    fn value ->
      case Map.fetch(mapping, value) do
        {:ok, _} = found -> found
        :error -> {:error, {:must_be_one_of, Map.keys(mapping)}}
      end
    end
  end

end
