defprotocol Monoid do
  @spec empty(Any) :: t()
  @doc "Нейтральный элемент для типа T"
  def empty(stub)

  @doc "Ассоциативная операция для объединения двух элементов типа T"
  def combine(a, b)
end
