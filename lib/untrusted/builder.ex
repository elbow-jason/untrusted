defmodule Untrusted.Builder do
  alias Untrusted.{Validation, Resolver}

  def build(namespaces, validations) do
    validations
    |> Enum.reduce(%{}, fn entry, acc ->
      Untrusted.Builder.update_mapping(acc, Untrusted.Builder.build_one(namespaces, entry))
    end)
    |> Enum.map(fn {_, validation} ->
      Untrusted.Builder.post_process(validation)
    end)
  end

  def post_process(%Validation{functions: funcs, required?: required?, list?: list?, forced?: forced?} = validation) do
    %Validation{
      validation
      | functions: funcs |> List.flatten(),
        required?: ensure_boolean(required?, true),
        list?: ensure_boolean(list?, false),
        forced?: ensure_boolean(forced?, false)
    }
  end

  defp ensure_boolean(nil, default), do: default
  defp ensure_boolean(true, _default), do: true
  defp ensure_boolean(false, _default), do: false

  def build_one(modules, {field_key, funcs}) when is_list(funcs) do
    Enum.map(funcs, fn func -> build_one(modules, {field_key, func}) end)
  end

  def build_one(_modules, %Validation{} = validation) do
    validation
  end

  def build_one(_modules, {_field_key, %Validation{} = validation}) do
    validation
  end

  def build_one(_modules, {field_key, :force}) do
    %Validation{field: field_key, forced?: true}
  end

  def build_one(_modules, {field_key, :list}) do
    %Validation{field: field_key, list?: true}
  end

  def build_one(_modules, {field_key, :optional}) do
    %Validation{field: field_key, required?: false}
  end

  def build_one(_modules, {field_key, :required}) do
    %Validation{field: field_key, required?: true}
  end

  def build_one(modules, {field_key, func_or_module} = entry) when is_atom(func_or_module) do
    case find_function([func_or_module], :validate, 1) do
      {:ok, module, function, arity} ->
        %Validation{field: field_key, functions: [{module, function, arity}]}

      {:error, _} ->
        %Validation{field: field_key, functions: [find_function!(modules, entry)]}
    end
  end

  def build_one(_modules, {field_key, func}) when is_function(func, 1) do
    %Validation{field: field_key, functions: [func]}
  end

  def update_mapping(mapping, validations) when is_list(validations) do
    Enum.reduce(validations, mapping, fn validation, acc -> update_mapping(acc, validation) end)
  end

  def update_mapping(mapping, %Validation{} = validation) do
    mapping
    |> add_function(validation)
    |> update_required(validation)
  end

  defp add_function(mapping, %Validation{functions: []}) do
    mapping
  end

  defp add_function(mapping, %Validation{field: field_key, functions: more_functions} = validation) do
    Map.update(mapping, field_key, validation, fn %Validation{functions: functions} = prev ->
      %Validation{prev | functions: [more_functions | functions]}
    end)
  end

  defp put_required(%Validation{required?: nil} = validation, value) when is_boolean(value) do
    %Validation{validation | required?: value}
  end

  defp put_required(%Validation{} = validation, _) do
    validation
  end

  defp update_required(mapping, %Validation{field: field_key, required?: required} = validiation) do
    Map.update(mapping, field_key, validiation, fn prev -> put_required(prev, required) end)
  end

  defp find_function!(modules, {_field, function_name}) when is_atom(function_name) do
    find_function!(modules, function_name)
  end

  defp find_function!(_module, {_field, function}) when is_function(function, 1) do
    function
  end

  defp find_function!(modules, function_name) when is_list(modules) and is_atom(function_name) do
    find_function!(modules, function_name, 1)
  end

  defp find_function!(modules, function_name, arity) do
    Resolver.resolve_module_function!(modules, function_name, arity)
  end

  defp find_function(modules, function_name, arity) when is_list(modules) and is_atom(function_name) and is_integer(arity) do
    Resolver.resolve_module_function(modules, function_name, arity)
  end
end
