defmodule Untrusted.BuilderTest do
  use ExUnit.Case
  alias Untrusted.{Validation, Builder, TestExample}
  require Untrusted.Builder

  describe "build_mapping/1" do
    @namespaces TestExample.__untrusted__(:namespaces)
    test "required? is defaulted to true when neither optional nor required is specified" do
      assert [
        %Validation{
          field: :count,
          required?: true,
          functions: [{Untrusted.Validators, :integer, 1}],
          list?: false,
        }
      ] == Builder.build(@namespaces, [count: :integer])
    end

    test "required? is assigned explicitly :required fields" do
      assert [
        %Validation{
          field: :count,
          required?: true,
          list?: false,
        }
      ] = Builder.build(@namespaces, [count: :required])
    end

    test "optional field sets reqiured? to false" do
      assert [
        %Validation{
          field: :count,
          functions: [],
          required?: false,
          list?: false,
        }
      ] = Builder.build(@namespaces, [count: :optional])
    end

    test "sets list? to true for lists" do
      assert [
        %Validation{
          field: :count,
          functions: [],
          required?: true,
          list?: true,
        }
      ] == Builder.build(@namespaces, [count: :list])
    end
  end
end
