defmodule RbSet do
  @moduledoc """
  Realization Set data structure base on Red Black Tree.
  """

  alias RbTree

  defstruct set: nil

  @opaque t :: %__MODULE__{
      root: RbTree.t() | nil,
  }

  @spec new() :: RbSet.t()
  def new() do
    %RbSet{set: RbTree.new()}
  end

  @spec new(list :: list(Comparable.t())) :: RbSet.t()
  def new(list) do
    Enum.reduce(list, new(), fn x, acc -> insert(acc, x) end)
  end

  @spec delete(set :: RbSet.t(), value :: Comparable.t()) :: RbSet.t()
  def delete(_set, _value) do
    raise "Not implemented yet"
  end

  @spec insert(set :: RbSet.t(), value :: Comparable.t()) :: RbSet.t()
  def insert(%RbSet{root: nil}, value) do
    %RbSet{root: Node.new_root_node(value)}
  end

  @spec insert(set :: RbSet.t(), value :: Comparable.t()) :: RbSet.t()
  def insert(%RbSet{root: root_node}, value) do
    %RbSet{root: do_insert(root_node, value)}
  end

  defp do_insert(curr_node, value) do
    case Comparable.compare(value, curr_node.value) do
      :lt ->
        if (curr_node.left == nil) do
          new_node = put_in(curr_node.left, Node.new_red_node(curr_node, value))
        else
          new_node = put_in(curr_node.left, do_insert(curr_node.left, value))
        end
      :gt ->
        if (curr_node.right == nil) do
          put_in(curr_node.right, Node.new_red_node(curr_node, value))
        else
          put_in(curr_node.right, do_insert(curr_node.right, value))
        end
      :eq ->
        curr_node
    end
  end

  @spec filter(set :: RbSet.t(), fun :: (Comparable.t() -> as_boolean(term()))) :: RbSet.t()
  def filter(_set, _fun) do
    raise "Not implemented yet"
  end

  @spec map(set :: RbSet.t(), fun :: (Comparable.t() -> Comparable.t())) :: RbSet.t()
  def map(_set, _fun) do
    raise "Not implemented yet"
  end

  @spec reduce_left(set :: RbSet.t(), acc :: any(), fun :: (Comparable.t(), any() -> any())) :: any()
  def reduce_left(_set, _acc, _fun) do
    raise "Not implemented yet"
  end

  @spec reduce_right(set :: RbSet.t(), acc :: any(), fun :: (Comparable.t(), any() -> any())) :: any()
  def reduce_right(_set, _acc, _fun) do
    raise "Not implemented yet"
  end

  @spec contains?(set :: RbSet.t(), value :: Comparable.t()) :: boolean()
  def contains?(_set, _value) do
    raise "Not implemented yet"
  end

  @spec equals?(set1 :: RbSet.t(), set2 :: RbSet.t()) :: boolean()
  def equals?(_set1, _set2) do
    raise "Not implemented yet"
  end

  defimpl Monoid do
    def empty(), do: RbSet.new()
    def combine(set1, set2) do
      raise "Not implemented yet"
    end
  end

  defimpl Collectable do
    def into(original) do
      raise "Not implemented yet"
    end
  end
end
