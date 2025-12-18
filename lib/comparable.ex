defprotocol Comparable do
  @spec compare(term(), term()) :: :lt | :eq | :gt
  def compare(a, b)
end

defmodule Comparable.Util do
  @compile {:no_warn_undefined, {:erlang, :compare, 2}}
  @spec order(term(), term()) :: :lt | :eq | :gt
  def order(a, b) do
    case :erlang.compare(a, b) do
      -1 -> :lt
      0 -> :eq
      1 -> :gt
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

# Фоллбек для прочих типов (PID, функции, порты и т.п.)
defimpl Comparable, for: Any do
  def compare(a, b), do: Comparable.Util.order(a, b)
end
