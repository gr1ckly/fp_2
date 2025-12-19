defmodule RbTree.Node do
  @moduledoc """
  Узел красно-черного дерева: цвет, ключ, значение и ссылки на потомков.
  """
  defstruct color: :red, key: nil, value: nil, left: nil, right: nil

  @opaque t :: %RbTree.Node{
            color: :red | :black,
            key: Comparable,
            value: Any,
            left: RbTree.Node.t() | nil,
            right: RbTree.Node.t() | nil
          }

  def new(color, key, value, left \\ nil, right \\ nil) do
    %RbTree.Node{
      color: color,
      key: key,
      value: value,
      left: left,
      right: right
    }
  end
end
