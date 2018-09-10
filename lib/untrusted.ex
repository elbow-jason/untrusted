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
      require Untrusted.Builder
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
      Untrusted.validate(__MODULE__, unquote(validations), unquote(params))
    end
  end

  defmacro validate(module, validations, params) do
    quote do
      require Untrusted.Builder

      unquote(module).__untrusted__(:namespaces)
      |> Untrusted.Builder.build(unquote(validations))
      |> Validation.run(unquote(params))
    end
  end

  defmacro build(validations) do
    quote do
      Untrusted.build(__MODULE__, unquote(validations))
    end
  end

  defmacro build(module, validations) do
    quote do
      require Untrusted.Builder
      Untrusted.Builder.build(unquote(module).__untrusted__(:namespaces), unquote(validations))
    end
  end
end
