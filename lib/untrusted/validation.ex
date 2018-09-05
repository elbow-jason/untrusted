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



  def run(validations, params) when is_list(validations) and is_map(params) do
    Enum.reduce(validations, {:ok, []}, fn validation, acc ->
      validation
      |> run_one(params)
      |> validation_reducer(acc)
    end)
    |> post_process()
  end

  defp run_one(%Validation{field: field} = validation, params) when is_map(params) do
    case {validation, Map.fetch(params, field)} do
      {_, {:ok, value}} ->
        run_with_value(validation, value)

      {%Validation{required?: true}, :error} ->
        error_required_key_not_found(validation, params)

      {%Validation{required?: false}, :error} ->
        :ok
    end
  end

  defp post_process({:error, _, errors}) when is_list(errors) do
    post_process({:error, errors})
  end

  defp post_process({:error, errors}) when is_list(errors) do
    {:error, errors |> List.flatten()}
  end

  defp post_process({:ok, validated}) when is_list(validated) do
    valid_params =
      validated
      |> List.flatten()
      |> Enum.into(%{})
    {:ok, valid_params}
  end
  defp post_process({:ok, _, validated}) do
    {:ok, validated}
  end
  defp post_process({:ok, _} = validated) do
    validated
  end

  defp validation_reducer({:error, _, error}, acc) do
    validation_reducer({:error, error}, acc)
  end

  defp validation_reducer(%Error{} = err, acc) do
    validation_reducer({:error, [err]}, acc)
  end

  defp validation_reducer({:ok, _, _}, {:error, errors}) do
    {:error, errors}
  end

  defp validation_reducer({:error, errors}, {:error, prev_errors}) do
    {:error, [errors | prev_errors]}
  end

  defp validation_reducer({:error, errors}, {:ok, _}) do
    {:error, errors}
  end

  defp validation_reducer({:ok, field_key, field_value}, {:ok, prev}) do
    {:ok, [{field_key, field_value} | prev]}
  end

  defp validation_reducer({:ok, valid_value}, {:ok, prev}) do
    {:ok, [valid_value | prev]}
  end

  defp validation_reducer({:ok, _}, {:error, errors}) when is_list(errors) do
    {:error, errors}
  end

  defp run_with_value(%Validation{list?: true} = validation, values) when is_list(values) do
    unlisty_validation = %Validation{validation | list?: false}
    Enum.reduce(values, {:ok, []}, fn value, acc ->
      unlisty_validation
      |> run_with_value(value)
      |> validation_reducer(acc)
    end)
  end
  defp run_with_value(%Validation{list?: true} = validation, value) when not is_list(value) do
    {:error, [into_error(validation, value, :must_be_a_list)]}
  end
  defp run_with_value(%Validation{functions: funcs, field: field_key}, value) do
    Enum.reduce(funcs, {:ok, []}, fn func, acc ->
      case func |> do_apply(value) do
        :ok ->
          {:ok, {field_key, value}}
        {:ok, valid_value} ->
          {:ok, {field_key, valid_value}}
        err ->
          err
      end
      |> validation_reducer(acc)
    end)
    |> check_errors(field_key, value)
  end

  defp check_errors({:ok, [{field_key, _}]} = okay, field_key, _), do: okay
  defp check_errors({:error, errors}, _, _) when is_list(errors), do: {:error, errors}
  defp check_errors({:error, reason}, field_key, value) when is_atom(reason) do
    {:error, [%Error{
      field: field_key,
      reason: reason,
      source: value,
    }]}
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
