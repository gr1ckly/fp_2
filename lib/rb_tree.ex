defmodule RbTree do
  alias RbTree.Node

  defstruct root: nil

  @opaque t :: %__MODULE__{
      root: Node.t() | nil,
  }

  @spec new() :: RbTree.t()
  def new() do
    %RbTree{}
  end

  @spec new(map :: map(Comparable.t())) :: RbTree.t()
  def new(map) do
    Enum.reduce(map, new(), fn {key, value}, acc -> insert(acc, key, value) end)
  end

  @spec insert(set :: RbTree.t(), key :: Comparable.t(), value :: Any) :: RbTree.t()
  def insert(%RbTree{root: nil}, key, value) do
    %RbTree{root: Node.new_root_node(key, value)}
  end

  @spec insert(set :: RbTree.t(), key :: Comparable.t(), value :: Any) :: RbTree.t()
  def insert(%RbTree{root: root_node}, key, value) do
    %RbTree{root: do_insert(root_node, key, value)}
  end

  defp do_insert(curr_node, key, value) do
    case Comparable.compare(key, curr_node.key) do
      :lt ->
        left_node = if (curr_node.left == nil) do
            Node.new_red_node(curr_node, key, value)
          else
            do_insert(curr_node.left, key, value)
          end
        do_balance(%Node{curr_node | left: left_node})
      :gt ->
        right_node = if (curr_node.right == nil) do
            Node.new_red_node(curr_node, key, value)
          else
            do_insert(curr_node.right, key, value)
          end
        do_balance(%Node{curr_node | right: right_node})
      :eq ->
        %Node{curr_node | color: :red,  value: value}
    end
  end

  defp do_balance(%Node{
    parent: nil
  } = root_node), do: %Node{root_node | color: :black}

  defp do_balance(%Node{
    right: %Node{color: :red, left: %Node{color: :red} = c_node} = p_node,
    left: %Node{color: :red} = u_node
  } = g_node) do
    invert_color(g_node)
  end

  defp do_balance(%Node{
    right: %Node{color: :red, left: %Node{color: :red} = c_node} = p_node,
    left: %Node{color: :black} = u_node
  } = g_node) do
    %Node{g_node | right: rotate_right(p_node)}
  end

  defp do_balance(%Node{
    right: %Node{color: :red, right: %Node{color: :red} = c_node} = p_node,
    left: %Node{color: :red} = u_node
  } = g_node) do
    invert_color(g_node)
  end

  defp do_balance(%Node{
    right: %Node{color: :red, right: %Node{color: :red} = c_node} = p_node,
    left: %Node{color: :black} = u_node
  } = g_node) do
    rotate_right(g_node)
  end

  defp do_balance(%Node{
    left: %Node{color: :red, left: %Node{color: :red} = c_node} = p_node,
    right: %Node{color: :red} = u_node
  } = g_node) do
    invert_color(g_node)
  end

  defp do_balance(%Node{
    left: %Node{color: :red, left: %Node{color: :red} = c_node} = p_node,
    right: %Node{color: :black} = u_node
  } = g_node) do
    rotate_left(g_node)
  end

  defp do_balance(%Node{
    left: %Node{color: :red, right: %Node{color: :red} = c_node} = p_node,
    right: %Node{color: :red} = u_node
  } = g_node) do
    invert_color(g_node)
  end

  defp do_balance(%Node{
    left: %Node{color: :red, right: %Node{color: :red} = c_node} = p_node,
    right: %Node{color: :black} = u_node
  } = g_node) do
    %Node{g_node | left: rotate_left(p_node)}
  end

  defp do_balance(node), do: node

  defp invert_color(%Node{color: curr_color, left: left_node, right: right_node} = node) do
    %Node{
      node
      | color: opponent_color(curr_color),
        left: fix_parent(node, :left, %Node{left_node | color: opponent_color(curr_color)}),
        right: fix_parent(node, :right, %Node{right_node | color: opponent_color(curr_color)})
    }
  end

  defp invert_color(%Node{color: curr_color, left: left_node, right: nil} = node) do
    %Node{node | color: opponent_color(curr_color),
      left: fix_parent(node, :left, %Node{left_node | color: opponent_color(curr_color)})}
  end

  defp invert_color(%Node{color: curr_color, left: nil, right: right_node} = node) do
    %Node{node | color: opponent_color(curr_color),
      right: fix_parent(node, :right, %Node{right_node | color: opponent_color(curr_color)})}
  end

  defp invert_color(%Node{color: curr_color, left: nil, right: nil} = node) do
    %Node{node | color: opponent_color(curr_color)}
  end

  defp opponent_color(:red), do: :black
  defp opponent_color(:black), do: :red

  defp rotate_left(%Node{right: %Node{} = y_node} = x_node) do
    beta = y_node.left

    new_x = %{x_node | right: beta}
    new_x = fix_parent(new_x, :right, beta)

    new_y = %{y_node | left: new_x, parent: x_node.parent}
    fix_parent(new_y, :left, new_x)
  end

  defp rotate_right(%Node{left: %Node{} = y_node} = x_node) do
    beta = y_node.right

    new_x = %{x_node | left: beta}
    new_x = fix_parent(new_x, :left, beta)

    new_y = %{y_node | right: new_x, parent: x_node.parent}
    fix_parent(new_y, :right, new_x)
  end

  defp fix_parent(parent, _field, nil), do: parent
  defp fix_parent(parent, field, %Node{} = child) do
    updated_child = %{child | parent: parent}
    put_in(parent, field, updated_child)
  end

  # Цветовые хелперы для fixup после удаления
  defp red?(%Node{color: :red}), do: true
  defp red?(_), do: false

  defp black?(nil), do: true
  defp black?(%Node{color: :black}), do: true
  defp black?(_), do: false

  # Fix-up красно-черного дерева для «двойного черного» после удаления
  defp delete_fixup(%Node{parent: nil} = node), do: %Node{node | color: :black}

  defp delete_fixup(%Node{} = node) do
    case node.parent.left do
      ^node -> fixup_left(node)
      _ -> fixup_right(node)
    end
  end

  defp fixup_left(%Node{parent: parent} = x) do
    s = parent.right || %Node{color: :black}
    s_left = if s, do: s.left, else: nil
    s_right = if s, do: s.right, else: nil

    cond do
      red?(s) ->
        parent = %{parent | color: :red}
        s = %{s | color: :black}
        parent = rotate_left(parent)
        x = parent.left
        fixup_left(x)

      black?(s) and black?(s_left) and black?(s_right) ->
        s = %{s | color: :red}
        parent = %{parent | right: s}
        if parent.color == :red, do: %{parent | color: :black}, else: delete_fixup(parent)

      black?(s) and red?(s_left) and black?(s_right) ->
        s = rotate_right(%{s | color: :black, left: %{s_left | color: :black}})
        parent = %{parent | right: s}
        fixup_left(%{x | parent: parent})

      black?(s) and red?(s_right) ->
        s = %{s | color: parent.color, right: %{s_right | color: :black}}
        parent = %{parent | color: :black, right: s}
        rotated = rotate_left(parent)
        fix_parent(rotated, :left, rotated.left)
    end
  end

  defp fixup_right(%Node{parent: parent} = x) do
    s = parent.left || %Node{color: :black}
    s_left = if s, do: s.left, else: nil
    s_right = if s, do: s.right, else: nil

    cond do
      red?(s) ->
        parent = %{parent | color: :red}
        s = %{s | color: :black}
        parent = rotate_right(parent)
        x = parent.right
        fixup_right(x)

      black?(s) and black?(s_left) and black?(s_right) ->
        s = %{s | color: :red}
        parent = %{parent | left: s}
        if parent.color == :red, do: %{parent | color: :black}, else: delete_fixup(parent)

      black?(s) and red?(s_right) and black?(s_left) ->
        s = rotate_left(%{s | color: :black, right: %{s_right | color: :black}})
        parent = %{parent | left: s}
        fixup_right(%{x | parent: parent})

      black?(s) and red?(s_left) ->
        s = %{s | color: parent.color, left: %{s_left | color: :black}}
        parent = %{parent | color: :black, left: s}
        rotated = rotate_right(parent)
        fix_parent(rotated, :right, rotated.right)
    end
  end

  @spec delete(set::RbTree.t(), key :: Comparable.t()) :: RbTree.t()
  def delete(tree, key) do
    vertex = find_vertex(tree.root, key)
    %RbTree{root: do_delete(vertex)}
  end

  defp find_vertex(%Node{
    parent: %Node{} = parent,
    left: %Node{} = left,
    right: %Node{} = right,
    key: Comparable.t() = node_key,
  } = curr_node, key) do
    case Comparable.compare(key, node_key) do
      :lt ->
        find_vertex(left, key)
      :gt ->
        find_vertex(right, key)
      :eq ->
        curr_node
      end
  end

  defp do_delete(%Node{
    parent: %Node{
      left: curr_node,
    } = parent,
    left: %Node{
      key: nil,
      color: :black,
    } = left,
    right: %Node{
      key: nil,
      color: :black,
    } = right,
    key: key,
  } = curr_node) do
    fix_parent(parent, :left, right)
  end

  defp do_delete(%Node{
    parent: %Node{
      right: curr_node,
    } = parent,
    left: %Node{
      key: nil,
      color: :black,
    } = left,
    right: %Node{
      key: nil,
      color: :black,
    } = right,
    key: key,
  } = curr_node) do
    fix_parent(parent, :right, left)
  end

  defp do_delete(%Node{
    parent: %Node{
      right: curr_node,
    } = parent,
    left: %Node{
      key: Comparable.t() = left_key,
    } = left,
    right: %Node{
      key: nil,
      color: :black,
    } = right,
  } = curr_node) do
    fix_parent(parent, :right, left)
  end

  defp do_delete(%Node{
    parent: %Node{
      left: curr_node,
    } = parent,
    left: %Node{
      key: Comparable.t() = left_key,
    } = left,
    right: %Node{
      key: nil,
      color: :black,
    } = right,
  } = curr_node) do
    fix_parent(parent, :left, left)
  end

  defp do_delete(%Node{
    parent: %Node{
      right: curr_node,
    } = parent,
    right: %Node{
      key: Comparable.t() = left_key,
    } = right,
    left: %Node{
      key: nil,
      color: :black,
    } = left,
  } = curr_node) do
    fix_parent(parent, :right, right)
  end

  defp do_delete(%Node{
    parent: %Node{
      left: curr_node,
    } = parent,
    right: %Node{
      key: Comparable.t() = right_key,
    } = right,
    left: %Node{
      key: nil,
      color: :black,
    } = left,
  } = curr_node) do
    fix_parent(parent, :left, right)
  end

  defp do_delete(%Node{
    left: %Node{
      key: Comparable.t() = left_key,
    } = left,
    right: %Node{
      key: Comparable.t() = right_key,
    } = right,
    key: Comparable.t() = curr_key,
    color: curr_color,
  } = curr_node) do
    {min_node, min_key} = find_min(right, right_key)
    case min_node.color do
      case :red ->
        new_right = do_delete(min_node)
        %Node{curr_node | key: min_key, right: new_right}
      case :black ->
        delete_fixup(min_node.right)
        %Node{curr_node | key: min_key}
    end
  end

  defp delete_fixup(%Node{} = curr_node) do
    raise "TODO"
  end

  defp find_min(%Node{key: Comparable.t() = min_key} = curr_node) do
    case curr_node.left do
      %Node{} = left_node ->
        find_min(left_node)
      nil ->
        {curr_node, min_key}
    end
  end

  @spec filter(tree::RbTree.t(), fun :: (Comparable.t() -> boolean())) :: RbTree.t()
  def filter(tree, fun), do: %RbTree{root: filter_node(tree.root, fun, nil)}

  defp filter_node(nil, _fun, acc), do: acc
  defp filter_node(%Node{} = node, fun, acc) do
    acc = filter_node(node.left, fun, acc)
    acc =
      if fun.({node.key, node.value}) do
        insert(%RbTree{root: acc}, node.key, node.value).root
      else
        acc
      end
    filter_node(node.right, fun, acc)
  end

  @spec map(set::RbTree.t(), fun :: (Comparable.t() -> Comparable.t())) :: RbTree.t()
  def map(_set, _fun) do
    raise "TODO"
  end

  @spec get(set :: RbTree.t(), key :: Comparable.t()) :: {:ok, Comparable.t()} | {:none, nil}
  def get(%RbTree{root: curr_node}, key) do
    case Comparable.compare(key, curr_node.key) do
      :lt ->
        get(%RbTree{root: curr_node.left}, key)
      :gt ->
        get(%RbTree{root: curr_node.right}, key)
    end
  end

  @spec get(set :: RbTree.t(), key :: Comparable.t()) :: {:ok, Comparable.t()} | {:none, nil}
  def get(%RbTree{root: key}, key) do
    {:ok, curr_node.value}
  end

  @spec get(set :: RbTree.t(), key :: Comparable.t()) :: {:ok, Comparable.t()} | {:none, nil}
  def get(%RbTree{root: nil}, _key) do
    {:none, nil}
  end

  @spec key_first(set :: RbTree.t()) :: {:ok, Comparable.t()} | {:none, nil}
  def get_first(%RbTree{root: nil}) do
    {:none, nil}
  end

  def key_first(%RbTree{root: curr_node}) do
    {:ok, curr_node.key}
  end

  def equal?(%RbTree{root: first_root} = first, %RbTree{root: second_root} = second) do

  end
end
