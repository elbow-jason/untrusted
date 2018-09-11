defmodule Untrusted.Context do
  alias Untrusted.{
    Context
  }

  defstruct validations: [],
            validated: %{},
            errors: [],
            params: nil

  def put_error(%Context{errors: prev} = ctx, %{} = error) do
    %Context{ctx | errors: [error | prev]}
  end

  def put_error(%Context{} = ctx, errors) when is_list(errors) do
    Enum.reduce(errors, ctx, fn err, ctx_acc -> Context.put_error(ctx_acc, err) end)
  end

  def put_validated(%Context{validated: prev} = ctx, key, value) do
    %Context{ctx | validated: Map.put(prev, key, value)}
  end
end
