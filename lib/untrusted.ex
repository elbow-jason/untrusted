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

      def get_validator() do
        get_validator(:__default__)
      end

      def get_validator(name) do
        Map.get(@validators_map, name)
      end

      def run_validations(validations, params) do
        Untrusted.Validation.run(validations, params)
      end

      def build_validations(validations) do
        Untrusted.Builder.build(@namespaces, validations)
      end
    end
  end

  defmacro build(validations) do
    quote do
      if is_nil(@namespaces) do
        raise "Untrusted.build/1 requires the :namespaces provided by the `use Untrusted` macro."
      end
      Untrusted.build(@namespaces, unquote(validations))
    end
  end

  defmacro build(namespaces, validations) do
    quote do
      Untrusted.Builder.build(unquote(namespaces), unquote(validations))
    end
  end

  def run_validations(validations, params) do
    Untrusted.Validation.run(validations, params)
  end
end
