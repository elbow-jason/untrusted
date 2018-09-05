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
        validation
        |> run_with_value(value)
        |> post_process()
      {%Validation{required?: true}, :error} ->
        error_required_key_not_found(validation, params)

      {%Validation{required?: false}, :error} ->
        nil
    end
  end

  def run(validations, params) when is_list(validations) and is_map(params) do
    Enum.reduce(validations, {:ok, []}, fn validation, acc ->
      validation
      |> run(params)
      |> validation_reducer(acc)
    end)
    |> post_process()
  end
  def run(%Validation{} = validation, value) do
    case run_with_value(validation, value) do
      {:ok, _, validated_value} ->
        {:ok, validated_value}
      {:error, _, error} ->
        {:error, error}
    end
    |> post_process
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

  defp run_with_value(%Validation{list?: true} = validation, values) when is_list(values) do
    unlisty_validation = %Validation{validation | list?: false}
    Enum.reduce(values, {:ok, []}, fn value, acc ->
      unlisty_validation
      |> run_with_value(value)
      |> validation_reducer(acc)
    end)
  end
  defp run_with_value(%Validation{list?: true, field: field_key} = validation, value) when not is_list(value) do
    check_errors({%{}, [into_error(validation, value, :must_be_a_list)]}, field_key)
  end
  defp run_with_value(%Validation{functions: funcs, field: field_key} = validation, value) do
    Enum.reduce(funcs, {[], []}, fn func, {values, errors} ->
      case do_apply(func, value) do
        :ok ->
          {[{field_key, value} | values], errors}
        {:ok, valid_value} ->
          {[{field_key, valid_value} | values], errors}
        {:error, more_errors} when is_list(more_errors) ->
          {values, [more_errors | errors]}
        {:error, reason} when is_atom(reason) ->
          {values, [into_error(validation, value, reason) | errors]}
      end
    end)
    |> check_errors(field_key)
  end

  defp check_errors({valid_value, []}, field_key), do: {:ok, field_key, valid_value}
  defp check_errors({_, errors}, field_key) when is_list(errors), do: {:error, field_key, errors}

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
