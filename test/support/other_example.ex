defmodule Untrusted.OtherExample do
  use Untrusted

  validator [
    count: :non_neg_integer
  ]

end
