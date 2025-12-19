defmodule RbTree do
  @moduledoc """
  Левостороннее красно-черное дерево.
  """
  alias RbTree.Node

  defstruct root: nil

  @opaque t :: %__MODULE__{root: Node.t() | nil}

  @spec new() :: t()
  def new, do: %RbTree{}

  @spec new(enum :: Enumerable.t()) :: t()
  def new(enum) do
    Enum.reduce(enum, new(), fn {key, value}, acc -> insert(acc, key, value) end)
  end

  @spec insert(t(), Comparable.t(), any()) :: t()
  def insert(%RbTree{root: root} = tree, key, value) do
    %RbTree{tree | root: root |> do_insert(key, value) |> black_root()}
  end

  defp do_insert(nil, key, value), do: Node.new(:red, key, value)

  defp do_insert(
         %Node{key: node_key, left: left, right: right, value: _ignored} = curr_node,
         new_key,
         new_value
       ) do
    case Comparable.compare(new_key, node_key) do
      :lt -> balance(%Node{curr_node | left: do_insert(left, new_key, new_value)})
      :gt -> balance(%Node{curr_node | right: do_insert(right, new_key, new_value)})
      :eq -> %Node{curr_node | value: new_value}
    end
  end

  defp black_root(%Node{} = curr_node), do: %Node{curr_node | color: :black}
  defp black_root(nil), do: nil

  defp balance(%Node{
         color: :black,
         left: %Node{
           color: :red,
           left: %Node{color: :red} = left_left,
           key: left_key,
           value: left_value,
           right: left_right
         },
         key: root_key,
         value: root_value,
         right: right_subtree
       }) do
    %Node{
      color: :red,
      key: left_key,
      value: left_value,
      left: %Node{left_left | color: :black},
      right: %Node{
        color: :black,
        key: root_key,
        value: root_value,
        left: left_right,
        right: right_subtree
      }
    }
  end

  defp balance(%Node{
         color: :black,
         left: %Node{
           color: :red,
           right: %Node{color: :red} = left_right,
           key: left_key,
           value: left_value,
           left: left_left
         },
         key: root_key,
         value: root_value,
         right: right_subtree
       }) do
    %Node{
      color: :red,
      key: left_right.key,
      value: left_right.value,
      left: %Node{
        color: :black,
        key: left_key,
        value: left_value,
        left: left_left,
        right: left_right.left
      },
      right: %Node{
        color: :black,
        key: root_key,
        value: root_value,
        left: left_right.right,
        right: right_subtree
      }
    }
  end

  defp balance(%Node{
         color: :black,
         right: %Node{
           color: :red,
           right: %Node{color: :red} = right_right,
           key: right_key,
           value: right_value,
           left: right_left
         },
         key: root_key,
         value: root_value,
         left: left_subtree
       }) do
    %Node{
      color: :red,
      key: right_key,
      value: right_value,
      left: %Node{
        color: :black,
        key: root_key,
        value: root_value,
        left: left_subtree,
        right: right_left
      },
      right: %Node{right_right | color: :black}
    }
  end

  defp balance(%Node{
         color: :black,
         right: %Node{
           color: :red,
           left: %Node{color: :red} = right_left,
           key: right_key,
           value: right_value,
           right: right_right
         },
         key: root_key,
         value: root_value,
         left: left_subtree
       }) do
    %Node{
      color: :red,
      key: right_left.key,
      value: right_left.value,
      left: %Node{
        color: :black,
        key: root_key,
        value: root_value,
        left: left_subtree,
        right: right_left.left
      },
      right: %Node{
        color: :black,
        key: right_key,
        value: right_value,
        left: right_left.right,
        right: right_right
      }
    }
  end

  defp balance(node), do: node

  @spec delete(t(), Comparable.t()) :: t()
  def delete(%RbTree{root: nil} = tree, _key), do: tree

  def delete(%RbTree{root: root} = tree, key) do
    new_root =
      root
      |> do_delete(key)
      |> black_root()

    %RbTree{tree | root: new_root}
  end

  defp do_delete(nil, _key), do: nil

  defp do_delete(%Node{} = node, key) do
    compare = Comparable.compare(key, node.key)

    node
    |> maybe_delete_left(compare, key)
    |> maybe_delete_right(compare, key)
  end

  defp maybe_delete_left(node, :lt, key) do
    node
    |> ensure_left_has_red()
    |> update_left(key)
  end

  defp maybe_delete_left(node, _compare, _key), do: node

  defp update_left(%Node{} = node, key), do: %Node{node | left: do_delete(node.left, key)}

  defp ensure_left_has_red(%Node{} = node) do
    if node.left && !red?(node.left) && !red?(node.left.left) do
      move_red_left(node)
    else
      node
    end
  end

  defp maybe_delete_right(node, :lt, _key), do: node

  defp maybe_delete_right(node, compare, key) do
    node
    |> rotate_if_left_red()
    |> handle_right(compare, key)
  end

  defp rotate_if_left_red(%Node{} = node) do
    if red?(node.left) do
      rotate_right(node)
    else
      node
    end
  end

  defp handle_right(%Node{right: nil}, :eq, _key), do: nil

  defp handle_right(%Node{} = node, _compare, key) do
    node = ensure_right_has_red(node)

    if node && Comparable.compare(key, node.key) == :eq do
      {min_key, min_value} = min_node(node.right)

      %Node{node | key: min_key, value: min_value, right: delete_min(node.right)}
      |> fix_up()
    else
      %Node{node | right: do_delete(node.right, key)} |> fix_up()
    end
  end

  defp ensure_right_has_red(%Node{} = node) do
    if node.right && !red?(node.right) && !red?(node.right.left) do
      move_red_right(node)
    else
      node
    end
  end

  defp delete_min(%Node{left: nil}), do: nil

  defp delete_min(%Node{} = node) do
    node =
      if node.left && !red?(node.left) && !red?(node.left.left) do
        move_red_left(node)
      else
        node
      end

    %Node{node | left: delete_min(node.left)} |> fix_up()
  end

  defp min_node(%Node{left: nil, key: key, value: value}), do: {key, value}
  defp min_node(%Node{left: left}), do: min_node(left)

  defp red?(%Node{color: :red}), do: true
  defp red?(_), do: false

  defp rotate_left(%Node{right: %Node{} = pivot} = parent) do
    %Node{
      pivot
      | color: parent.color,
        left: %Node{parent | color: :red, right: pivot.left}
    }
  end

  defp rotate_right(%Node{left: %Node{} = pivot} = parent) do
    %Node{
      pivot
      | color: parent.color,
        right: %Node{parent | color: :red, left: pivot.right}
    }
  end

  defp flip_colors(%Node{left: left, right: right} = node) do
    %Node{
      node
      | color: flip(node.color),
        left:
          case left do
            %Node{} = l -> %Node{l | color: flip(l.color)}
            nil -> nil
          end,
        right:
          case right do
            %Node{} = r -> %Node{r | color: flip(r.color)}
            nil -> nil
          end
    }
  end

  defp flip(:red), do: :black
  defp flip(:black), do: :red

  defp move_red_left(%Node{} = node) do
    node = flip_colors(node)

    if node.right && red?(node.right.left) do
      node = %Node{node | right: rotate_right(node.right)} |> rotate_left()
      flip_colors(node)
    else
      node
    end
  end

  defp move_red_right(%Node{} = node) do
    node = flip_colors(node)

    if node.left && red?(node.left.left) do
      node = rotate_right(node)
      flip_colors(node)
    else
      node
    end
  end

  defp fix_up(%Node{} = node) do
    node =
      if red?(node.right) && !red?(node.left) do
        rotate_left(node)
      else
        node
      end

    node =
      if red?(node.left) && red?(node.left.left) do
        rotate_right(node)
      else
        node
      end

    node =
      if red?(node.left) && red?(node.right) do
        flip_colors(node)
      else
        node
      end

    node
  end

  @spec get(t(), Comparable.t()) :: {:ok, any()} | {:none, nil}
  def get(%RbTree{root: nil}, _key), do: {:none, nil}

  def get(%RbTree{root: %Node{key: node_key, left: left, right: right, value: value}}, key) do
    case Comparable.compare(key, node_key) do
      :lt -> get(%RbTree{root: left}, key)
      :gt -> get(%RbTree{root: right}, key)
      :eq -> {:ok, value}
    end
  end

  @spec get_first(t()) :: {:ok, {Comparable.t(), any()}} | {:none, nil}
  def get_first(%RbTree{root: nil}), do: {:none, nil}
  def get_first(%RbTree{root: root}), do: do_get_first(root)

  defp do_get_first(nil), do: {:none, nil}
  defp do_get_first(%Node{left: nil, key: nil}), do: {:none, nil}
  defp do_get_first(%Node{left: nil} = node), do: {:ok, {node.key, node.value}}
  defp do_get_first(%Node{left: left}), do: do_get_first(left)

  @spec equal?(t(), t()) :: boolean()
  def equal?(tree1, tree2) do
    Enum.sort(to_list(tree1, [])) == Enum.sort(to_list(tree2, []))
  end

  @spec to_list(Node.t() | t() | nil, list()) :: list({Comparable.t(), any()})
  def to_list(%RbTree{root: root}, acc), do: to_list(root, acc)
  def to_list(nil, acc), do: acc

  def to_list(%Node{} = node, acc) do
    acc = to_list(node.left, acc)
    acc = [{node.key, node.value} | acc]
    to_list(node.right, acc)
  end

  @spec fold_keyl(t(), any(), (any(), Comparable.t() -> any())) :: any()
  def fold_keyl(tree, acc, func) do
    tree
    |> to_list([])
    |> Enum.sort_by(fn {key, _value} -> key end)
    |> Enum.reduce(acc, fn {key, _value}, current_acc -> func.(current_acc, key) end)
  end

  @spec fold_keyr(t(), any(), (any(), Comparable.t() -> any())) :: any()
  def fold_keyr(tree, acc, func) do
    tree
    |> to_list([])
    |> Enum.sort_by(fn {key, _value} -> key end)
    |> Enum.reverse()
    |> Enum.reduce(acc, fn {key, _value}, current_acc -> func.(current_acc, key) end)
  end

  @spec filter(t(), (Comparable.t() -> as_boolean(term()))) :: t()
  def filter(tree, fun) do
    tree
    |> to_list([])
    |> Enum.filter(fn {key, _value} -> fun.(key) end)
    |> RbTree.new()
  end

  defimpl Monoid do
    @spec empty(any()) :: RbTree.t()
    def empty(_), do: RbTree.new()

    @spec combine(RbTree.t(), RbTree.t()) :: RbTree.t()
    def combine(tree1, tree2) do
      Enum.reduce(RbTree.to_list(tree2, []), tree1, fn {key, value}, acc ->
        RbTree.insert(acc, key, value)
      end)
    end
  end

  defimpl Collectable do
    @spec into(RbTree.t()) :: {RbTree.t(), (any(), :done | :halt | {any(), any()} -> any())}
    def into(%RbTree{} = tree) do
      collector_fun = fn
        current_tree, {:cont, {key, value}} -> RbTree.insert(current_tree, key, value)
        current_tree, :done -> current_tree
        _current_tree, :halt -> :ok
      end

      {tree, collector_fun}
    end
  end
end
