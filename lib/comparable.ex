defprotocol Comparable do
  @spec compare(term(), term()) :: :lt | :eq | :gt
  def compare(a, b)
end

defmodule Comparable.Util do
  @moduledoc """
  Вспомогательные функции для сравнения с приведением к :lt/:eq/:gt.
  """
  @spec order(term(), term()) :: :lt | :eq | :gt
  def order(a, b) do
    cond do
      a === b -> :eq
      a < b -> :lt
      true -> :gt
    end
  end
end

defimpl Comparable, for: Integer do
  def compare(a, b), do: Comparable.Util.order(a, b)
end

defimpl Comparable, for: Float do
  def compare(a, b), do: Comparable.Util.order(a, b)
end

defimpl Comparable, for: BitString do
  def compare(a, b), do: Comparable.Util.order(a, b)
end

defimpl Comparable, for: Atom do
  def compare(a, b), do: Comparable.Util.order(a, b)
end

defimpl Comparable, for: Tuple do
  def compare(a, b), do: Comparable.Util.order(a, b)
end

defimpl Comparable, for: List do
  def compare(a, b), do: Comparable.Util.order(a, b)
end

defimpl Comparable, for: Map do
  def compare(a, b), do: Comparable.Util.order(a, b)
end
