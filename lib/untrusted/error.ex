defmodule Untrusted.Error do
  @type string_like :: atom | String.t()

  @type t :: %__MODULE__{
          reason: string_like | {string_like, any},
          field: any,
          source: any
        }

  defstruct [:reason, :field, :source]
end
