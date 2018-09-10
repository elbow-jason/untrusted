defmodule Untrusted do
  @moduledoc """
  Documentation for Untrusted.
  """

  alias Untrusted.{
    Validation,
    Builder
  }

  defmacro __using__(kwargs \\ []) do
    quote do
      require Untrusted
      import Untrusted.ValidatorFunctions

      kwargs = unquote(kwargs)
      @namespaces Keyword.get(kwargs, :namespaces, []) ++ [Untrusted.Validators]
      def __untrusted__(:namespaces) do
        @namespaces
      end
    end
  end

  defmacro validate(validations, params) do
    quote do
      __MODULE__
      |> Untrusted.build(unquote(validations))
      |> Validation.run(unquote(params))
    end
  end

  def validate(module, validations, params) when is_atom(module) do
    module
    |> Builder.build(validations)
    |> Validation.run(params)
  end

  defmacro build(validations) do
    quote do
      Untrusted.build(__MODULE__, unquote(validations))
    end
  end

  defmacro build(module, validations) do
    quote do
      Untrusted.Builder.build(unquote(module).__untrusted__(:namespaces), unquote(validations))
    end
  end

end
