defmodule RbTree.Node do
  defstruct color: :red, key: nil, value: nil, left: nil, right: nil, parent: nil

  @opaque t :: %RbTree.Node{
            color: :red | :black,
            key: Comparable,
            value: Any,
            left: RbTree.Node.t() | nil,
            right: RbTree.Node.t() | nil,
            parent: RbTree.Node.t() | nil
          }

  def new(color, key, value, left \\ nil, right \\ nil, parent \\ nil) do
    %RbTree.Node{
      color: color,
      key: key,
      value: value,
      left: left,
      right: right,
      parent: parent
    }
  end

  def new_root_node(key, value) do
    new(:black, key, value)
  end

  def new_red_node(parent, key, value) do
    curr_node = new(:red, key, value, nil, nil, parent)
    %RbTree.Node{curr_node | left: new(:black, nil, nil, nil, nil, curr_node), right: new(:black, nil, nil, nil, nil, curr_node)}
  end
end
