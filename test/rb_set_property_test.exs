defmodule RbSetPropertyTest do
  use ExUnit.Case
  use ExUnitProperties

  alias Monoid
  alias RbSet
  alias RbTree

  property "monoid empty" do
    check all(list <- list_of(integer())) do
      set = RbSet.new(list)
      empty = Monoid.empty(RbSet.new())

      assert RbSet.equals?(Monoid.combine(set, empty), set)
      assert RbSet.equals?(Monoid.combine(empty, set), set)
    end
  end

  property "monoid associativity" do
    check all(
            l1 <- list_of(integer()),
            l2 <- list_of(integer()),
            l3 <- list_of(integer())
          ) do
      s1 = RbSet.new(l1)
      s2 = RbSet.new(l2)
      s3 = RbSet.new(l3)

      first = Monoid.combine(Monoid.combine(s1, s2), s3)
      second = Monoid.combine(s1, Monoid.combine(s2, s3))

      assert RbSet.equals?(first, second)
    end
  end

  property "collectable" do
    check all(list <- list_of(integer())) do
      from_enum = Enum.into(list, RbSet.new())
      expected = RbSet.new(list)

      assert RbSet.equals?(from_enum, expected)
    end
  end

  property "double insert doesn't duplicate" do
    check all(
            list <- list_of(integer()),
            value <- integer()
          ) do
      set = RbSet.new(list) |> RbSet.insert(value)
      set_after = set |> RbSet.insert(value)

      assert RbSet.equals?(set, set_after)
    end
  end

  property "get_first returns minimum element" do
    check all(list <- list_of(integer(), min_length: 1)) do
      set = RbSet.new(list)
      min_key = Enum.min(list)

      assert RbSet.get_first(set) == min_key
    end
  end
end
