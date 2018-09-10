defmodule Untrusted.Validation do
  alias Untrusted.{
    Error,
    Validation,
    Context,
    Helpers
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
    %Context{
      validations: validations,
      params: params
    }
    |> run_context()
    |> unpack_context()
  end

  defp run_context(%Context{validations: validations} = ctx) do
    Enum.reduce(validations, ctx, fn validation, acc ->
      run_one(acc, validation)
    end)
  end

  defp unpack_context(%Context{errors: [], validated: validated}) do
    {:ok, validated}
  end

  defp unpack_context(%Context{errors: [_ | _] = errors}) do
    {:error, errors}
  end

  defp run_one(%Context{params: params} = ctx, %Validation{field: field} = validation) do
    case {validation, Helpers.map_fetch(params, field)} do
      {_, {:ok, value}} ->
        run_with_value(ctx, validation, value)

      {%Validation{required?: true}, :error} ->
        error = error_required_key_not_found(validation, params)
        Context.put_error(ctx, error)

      {%Validation{required?: false}, :error} ->
        ctx
    end
  end

  defp run_with_value(ctx, %Validation{list?: true} = validation, values) when is_list(values) do
    unlisty_validation = %Validation{validation | list?: false}

    Enum.reduce(values, ctx, fn value, ctx_acc ->
      run_with_value(ctx_acc, unlisty_validation, value)
    end)
  end

  defp run_with_value(ctx, %Validation{list?: true, field: key}, value) when not is_list(value) do
    error = into_error(key, value, :must_be_a_list)
    Context.put_error(ctx, error)
  end

  defp run_with_value(ctx, %Validation{list?: false, functions: funcs, field: key}, value) do
    Enum.reduce(funcs, ctx, fn func, ctx_acc ->
      apply_func(ctx_acc, func, key, value)
    end)
  end

  defp apply_func(ctx, func, key, value) do
    case do_apply(func, value) do
      :ok ->
        Context.put_validated(ctx, key, value)

      {:ok, valid_value} ->
        Context.put_validated(ctx, key, valid_value)

      {:error, reason} when is_atom(reason) or is_tuple(reason) ->
        Context.put_error(ctx, into_error(key, value, reason))

      {:error, errors} when is_list(errors) ->
        Context.put_error(ctx, errors)
    end
  end

  defp into_error(key, value, reason) do
    %Error{
      field: key,
      source: value,
      reason: reason
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
