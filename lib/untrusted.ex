defmodule Untrusted do
  @moduledoc """
  Documentation for Untrusted.
  """

  defmacro __using__(kwargs \\ []) do
    quote do
      require Untrusted
      kwargs = unquote(kwargs)
      @namespaces Keyword.get(kwargs, :namespaces, []) ++ [Untrusted.Validators]
      def __untrusted__(:namespaces) do
        @namespaces
      end
    end
  end

  defmacro validate(validations, params) do
    quote do
      unquote(validations)
      |> Untrusted.build()
      |> Untrusted.Validation.run(unquote(params))
    end
  end

  defmacro build(validations) do
    quote do
      Untrusted.Builder.build(__MODULE__.__untrusted__(:namespaces), unquote(validations))
    end
  end
end
