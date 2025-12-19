defmodule RbSetTest do
  use ExUnit.Case

  test "insert adds element and ignores duplicates" do
    set =
      RbSet.new()
      |> RbSet.insert(1)

    assert RbSet.contains?(set, 1)

    set_dup = RbSet.insert(set, 1)
    size = RbSet.foldl(set_dup, 0, fn acc, _key -> acc + 1 end)
    assert size == 1
  end

  test "delete removes element" do
    set =
      RbSet.new()
      |> RbSet.insert(1)
      |> RbSet.insert(2)

    set = RbSet.delete(set, 1)
    refute RbSet.contains?(set, 1)
    assert RbSet.contains?(set, 2)
  end

  test "equals? returns true for equal sets with different insertion orders" do
    set1 =
      RbSet.new()
      |> RbSet.insert(1)
      |> RbSet.insert(2)

    set2 =
      RbSet.new()
      |> RbSet.insert(2)
      |> RbSet.insert(1)

    assert RbSet.equals?(set1, set2)
  end

  test "equals? returns false for different sets" do
    set1 =
      RbSet.new()
      |> RbSet.insert(1)
      |> RbSet.insert(2)

    set2 =
      RbSet.new()
      |> RbSet.insert(1)

    refute RbSet.equals?(set1, set2)
  end

  test "Collectable builds set from enumerable" do
    set = Enum.into([{1, :a}, {2, :b}], RbSet.new())

    assert RbSet.contains?(set, 1)
    assert RbSet.contains?(set, 2)
    refute RbSet.contains?(set, 3)
  end

  test "combine unions two sets" do
    set1 =
      RbSet.new()
      |> RbSet.insert(1)
      |> RbSet.insert(2)

    set2 =
      RbSet.new()
      |> RbSet.insert(2)
      |> RbSet.insert(3)

    combined = Monoid.combine(set1, set2)

    assert RbSet.contains?(combined, 1)
    assert RbSet.contains?(combined, 2)
    assert RbSet.contains?(combined, 3)
  end
end
