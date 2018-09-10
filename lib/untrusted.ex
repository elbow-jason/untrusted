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

      def validate(validations, params) do
        @namespaces
        |> Builder.build(validations)
        |> Validation.run(params)
      end

      def build(validations) do
        Untrusted.Builder.build(@namespaces, validations)
      end

      def build(module, validations) when is_atom(module) do
        Untrusted.Builder.build(module.__untrusted__(:namespaces), validations)
      end
    end
  end

  def validate(module, validations, params) do
    module.__untrusted__(:namespaces)
    |> Builder.build(validations)
    |> Validation.run(params)
  end

  defmacro build(validations) do
    quote do
      require Untrusted.Builder
      Untrusted.Builder.build(__MODULE__.__untrusted__(:namespaces), unquote(validations))
    end
  end

  defmacro build(module, validations) do
    quote do
      require Untrusted.Builder
      Untrusted.Builder.build(unquote(module).__untrusted__(:namespaces), unquote(validations))
    end
  end
end
