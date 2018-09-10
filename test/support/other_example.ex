defmodule Untrusted.OtherExample do
  use Untrusted

  def validate(params) do
    validate([is_other?: :boolean], params)
  end
end
