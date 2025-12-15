defprotocol Monoid do
  @doc "Нейтральный элемент для типа T"
  def empty(type)

  @doc "Ассоциативная операция для объединения двух элементов типа T"
  def combine(a, b)
end
