defmodule Untrusted do
  @moduledoc """
  Documentation for Untrusted.
  """

  defmacro __using__(kwargs \\ []) do
    quote do
      kwargs = unquote(kwargs)
      @namespaces Keyword.get(kwargs, :namespaces, []) ++ [Untrusted.Validators]
      def __untrusted__(:namespaces) do
        @namespaces
      end

      Module.register_attribute(__MODULE__, :validations, accumulate: true)
      require Untrusted.Validator
      import Untrusted.Validator, only: [validator: 2, validator: 1]

      @before_compile Untrusted

    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @validators_map __MODULE__
        |> Module.get_attribute(:validations)
        |> Enum.into(%{})

      def __untrusted__(:validators) do
        @validators_map
      end

    end
  end
end
