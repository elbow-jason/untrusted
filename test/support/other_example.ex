defmodule Untrusted.OtherExample do
  use Untrusted

  def validate(params) do
    Untrusted.validate([is_other?: :boolean], params)
  end
end
