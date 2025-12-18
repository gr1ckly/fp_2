defmodule RbSet do
  @moduledoc """
  Realization Set data structure base on Red Black Tree.
  """

  alias RbTree

  defstruct set: nil

  @opaque t :: %__MODULE__{
      set: RbTree.t() | nil,
  }

  @spec new() :: RbSet.t()
  def new() do
    %RbSet{set: RbTree.new()}
  end

  @spec new(list :: list(Comparable.t())) :: RbSet.t()
  def new(list) do
    %RbSet{set: Map.new(list, fn x -> {x, nil} end) |> RbTree.new()}
  end

  @spec delete(set :: RbSet.t(), value :: Comparable.t()) :: RbSet.t()
  def delete(set, value) do
    %RbSet{set: RbTree.delete(set.set, value)}
  end

  @spec insert(set :: RbSet.t(), value :: Comparable.t()) :: RbSet.t()
  def insert(set, value) do
    %RbSet{set: RbTree.insert(set.set, value, nil)}
  end

  @spec filter(set :: RbSet.t(), fun :: (Comparable.t() -> as_boolean(term()))) :: RbSet.t()
  def filter(set, fun) do
    %RbSet{set: RbTree.filter(set.set, fun)}
  end

  @spec map(set :: RbSet.t(), fun :: (Comparable.t() -> Comparable.t())) :: RbSet.t()
  def map(set, fun) do
    new_set = Enum.reduce(RbTree.to_list(set.set.root, []), RbSet.new(), fn {key, _value}, acc ->
      RbSet.insert(acc, fun.(key))
    end)
    new_set
  end

  @spec foldl(set :: RbSet.t(), acc :: any(), fun :: (any(), Comparable.t() -> any())) :: any()
  def foldl(set, acc, func) do
    RbTree.fold_keyl(set.set, acc, func)
  end

  @spec foldr(set :: RbSet.t(), acc :: any(), fun :: (any(), Comparable.t() -> any())) :: any()
  def foldr(set, acc, func) do
    RbTree.fold_keyr(set.set, acc, func)
  end

  @spec contains?(set :: RbSet.t(), value :: Comparable.t()) :: boolean()
  def contains?(set, value) do
    {result, _} = RbTree.get(set.set, value)
    result != :none
  end

  @spec equals?(set1 :: RbSet.t(), set2 :: RbSet.t()) :: boolean()
  def equals?(set1, set2) do
    RbTree.equal?(set1.set, set2.set)
  end

  defimpl Monoid do
    @spec empty(Any) :: RbSet.t()
    def empty(_), do: RbSet.new()
    def combine(set1, set2) do
      %RbSet{set: Monoid.combine(set1.set, set2.set)}
    end
  end

  defimpl Collectable do
    @spec into(RbSet.t()) :: {RbSet.t(), (any(), :done | :halt | {any(), any()} -> any())}
    def into(%RbSet{} = curr_set) do
      collector_fun = fn
      curr_set, {:cont, {key, _value}} ->
        RbSet.insert(curr_set, key)

      curr_set, :done ->
        curr_set

      _curr_set, :halt ->
        :ok
    end
    initial_tree = curr_set
      {initial_tree, collector_fun}
    end
    end
end
