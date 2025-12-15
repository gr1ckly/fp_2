defprotocol Comparable do
  @spec compare(term(), term()) :: :lt | :eq | :gt
  def compare(a, b)
end

defimpl Comparable, for: Any do
  def compare(a, b), do: Kernel.compare(a, b)
end
