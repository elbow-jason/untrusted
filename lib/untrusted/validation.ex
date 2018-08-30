defmodule Untrusted.Validation do
  alias Untrusted.{
    Error,
    Validation
  }

  @type field_key :: any
  @type t :: %__MODULE__{
          field: field_key,
          required?: boolean | nil,
          list?: boolean,
          functions: list({module, atom, non_neg_integer, list(any)})
        }

  defstruct field: nil,
            required?: nil,
            list?: nil,
            functions: []

  def run(%Validation{field: field} = validation, params) when is_map(params) do
    case {validation, Map.fetch(params, field)} do
      {_, {:ok, value}} ->
        IO.puts("found #{inspect field} #{inspect value} for #{inspect validation}")
        run_with_value(validation, value)

      {%Validation{required?: true}, :error} ->
        IO.puts("not_found required #{inspect field} for #{inspect validation}")
        error_required_key_not_found(validation, params)

      {%Validation{required?: false}, :error} ->
        IO.puts("not_found optional #{inspect field} for #{inspect validation}")
        :ok
    end
  end

  def run(validations, params) when is_list(validations) do
    Enum.reduce(validations, [], fn validation, acc ->
      case run(validation, params) do
        [] -> acc
        :ok -> acc
        errors -> [errors | acc]
      end
    end)
    |> List.flatten()
  end

  def run(%Validation{} = validation, value) do
    run_with_value(validation, value)
  end

  defp run_with_value(%Validation{list?: true} = validation, values) when is_list(values) do
    unlisty_validation = %Validation{validation | list?: false}
    Enum.map(values, fn value -> run_with_value(unlisty_validation, value) end)
  end
  defp run_with_value(%Validation{list?: true} = validation, value) when not is_list(value) do
    [into_error(validation, value, :must_be_a_list)]
  end
  defp run_with_value(%Validation{functions: funcs} = validation, value) do
    Enum.reduce(funcs, [], fn func, errors ->
      case do_apply(func, value) do
        :ok ->
          errors
        more_errors when is_list(more_errors) ->
          [more_errors | errors]
        {:error, more_errors} when is_list(more_errors) ->
          [more_errors | errors]
        {:error, reason} when is_atom(reason) ->
          [into_error(validation, value, reason) | errors]
      end
    end)
  end

  defp into_error(%Validation{field: field}, value, reason) do
    %Error{
      field: field,
      reason: reason,
      source: value
    }
  end

  defp do_apply({module, function, _}, value) do
    apply(module, function, [value])
  end

  defp do_apply(func, value) when is_function(func, 1) do
    func.(value)
  end

  defp error_required_key_not_found(%Validation{field: field}, params) do
    %Error{
      reason: :key_is_required,
      field: field,
      source: params
    }
  end
end
