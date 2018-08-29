defmodule Untrusted.TestExample do
  defmodule Validators do
    def must_be_1(1), do: :ok
    def must_be_1(_), do: {:error, :not_one}
  end

  use Untrusted, namespaces: [Untrusted.TestExample.Validators]

  validator [
    name: :string
  ]

  validator :named_validator, [
    count: :non_neg_integer
  ]

  validator :list_tester, [
    items: [:list, :integer]
  ]

  validator :module_tester, [
    other: Untrusted.OtherExample
  ]

end
