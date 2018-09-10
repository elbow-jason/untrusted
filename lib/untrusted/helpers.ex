defmodule Untrusted.Helpers do
  def map_fetch(params, key) do
    with(
      :error <- Map.fetch(params, key),
      {:key, {:ok, swapped_key}} <- {:key, swap_key(key)},
      :error <- Map.fetch(params, swapped_key)
    ) do
      :error
    else
      {:key, :error} ->
        :error

      {:ok, _} = found ->
        found
    end
  end

  defp swap_key(key) when is_atom(key) do
    {:ok, to_string(key)}
  end

  defp swap_key(key) when is_binary(key) do
    try do
      {:ok, String.to_existing_atom(key)}
    rescue
      ArgumentError ->
        :error
    end
  end

  defp swap_key(_) do
    :error
  end
end
