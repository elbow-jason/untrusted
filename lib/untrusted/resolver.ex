defmodule Untrusted.Resolver do

  def unalias(module) do
    module
  end

  def unalias(module, %Macro.Env{aliases: aliases}) do
    aliases
    |> Enum.find(fn
      {^module, _} -> true
      _ -> false
    end)
    |> case do
      nil -> module
      {^module, the_alias} -> the_alias
    end
  end

  def resolve_module_function(modules, function_name, arity) when is_list(modules) do
    modules
    |> Enum.find(fn validator_module ->
      is_function?(validator_module, function_name, arity)
    end)
    |> case do
      nil ->
        {:error, :no_such_function}
      found_module ->
        {:ok, found_module, function_name, arity}
    end
  end

  def resolve_module_function(module, function_name, arity) when is_atom(module) do
    resolve_module_function([module], function_name, arity)
  end

  def resolve_module_function!(modules, function_name, arity) when is_list(modules) do
    case resolve_module_function(modules, function_name, arity) do
      {:error, :no_such_function} ->
        raise_no_such_function!(modules, function_name, arity)

      {:ok, found_module, function_name, arity} ->
        {found_module, function_name, arity}
    end
  end

  def resolve_module_function!(module, function_name, arity) when is_atom(module) do
    resolve_module_function!([module], function_name, arity)
  end

  def is_function?(module, function, arity) do
    ensure_loaded(module)
    function_exported?(module, function, arity)
  end

  def is_module?(module) when is_atom(module) do
    case Code.ensure_loaded(module) do
      {:module, _} -> true
      _ -> false
    end
  end
  def is_module?(_) do
    false
  end

  defp raise_no_such_function!(modules, function_name, arity) do
    pretty_modules = "[" <> prettify(modules) <> "]"

    raise CompileError,
      description: "Unable to resovle the function #{function_name}/#{arity} in any of the modules #{pretty_modules}"
  end

  defp raise_module_not_resolved!(module) do
    raise CompileError, description: "Unable to resolve module #{prettify(module)}"
  end

  defp prettify(module) when is_atom(module) do
    inspect(module)
  end

  defp prettify(modules) when is_list(modules) do
    modules
    |> Enum.map(fn mod ->
      mod
      |> ensure_loaded()
      |> prettify()
    end)
    |> Enum.join(", ")
  end

  defp ensure_loaded(module) do
    try do
      Code.ensure_loaded(module)
      module
    rescue
      _ ->
        module
    end
  end

  defp ensure_loaded!(module) do
    try do
      case Code.ensure_loaded(module) do
        {:module, _} ->
          module

        _ ->
          raise_module_not_resolved!(module)
      end
    rescue
      ArgumentError ->
        raise_module_not_resolved!(module)
    end
  end
end
