defmodule Untrusted.Validator do
  defmacro validator(kwargs) when is_list(kwargs) do
    quote do
      alias Untrusted.{Builder, Validation}

      @built Builder.build(Module.get_attribute(__MODULE__, :namespaces), unquote(kwargs))

      Module.register_attribute(__MODULE__, :validations, accumulate: true)
      Module.put_attribute(__MODULE__, :validations, {:__default__, @built})

      def validate(params) do
        Validation.run(@built, params)
      end
    end
  end

  defmacro validator(name, kwargs) do
    quote do
      alias Untrusted.{Builder, Validation}

      @built Builder.build(Module.get_attribute(__MODULE__, :namespaces), unquote(kwargs))

      Module.register_attribute(__MODULE__, :validations, accumulate: true)
      Module.put_attribute(__MODULE__, :validations, {unquote(name), @built})

      def validate(unquote(name), params) do
        Validation.run(@built, params)
      end
    end
  end
end
