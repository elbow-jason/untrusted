defmodule Untrusted.TestExample do
  defmodule Validators do
    def must_be_1(1), do: :ok
    def must_be_1(_), do: {:error, :not_one}
  end

  use Untrusted, namespaces: [Untrusted.TestExample.Validators]
  require Untrusted.OtherExample

  def has_name(params) do
    validate([name: :string], params)
  end

  def has_count(params) do
    validate([count: :non_neg_integer], params)
  end

  def int_list_item_tester(params) do
    validate([items: [:list, :integer]], params)
  end

  def module_tester(params) do
    validate([other: Untrusted.OtherExample], params)
  end

  def multiple_fields(params) do
    [
      count: :integer,
      age: :integer,
      number: :integer
    ]
    |> validate(params)
  end
end
