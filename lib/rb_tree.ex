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

  @spec new(map :: map()) :: RbTree.t()
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

  defp invert_color(%Node{color: curr_color} = node) do
    new_color = opponent_color(curr_color)
    new_left =
      case node.left do
        %Node{} = left_node -> fix_parent(node, :left, %Node{left_node | color: new_color})
        nil -> nil
      end

    new_right =
      case node.right do
        %Node{} = right_node -> fix_parent(node, :right, %Node{right_node | color: new_color})
        nil -> nil
      end

    %Node{node | color: new_color, left: new_left, right: new_right}
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

  defp red?(%Node{color: :red}), do: true
  defp red?(_), do: false

  defp black?(nil), do: true
  defp black?(%Node{color: :black}), do: true
  defp black?(_), do: false

  defp delete_fixup(nil), do: nil
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
  def delete(%RbTree{root: nil} = tree, _key), do: tree
  def delete(tree, key) do
    vertex = find_vertex(tree.root, key)
    %RbTree{root: do_delete(vertex)}
  end

  defp find_vertex(%Node{
    left: %Node{} = left,
    right: %Node{} = right,
    key: node_key,
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

  defp find_vertex(%Node{key: node_key} = curr_node, key)
       when curr_node.parent == nil do
    case Comparable.compare(key, node_key) do
      :lt -> find_vertex(curr_node.left, key)
      :gt -> find_vertex(curr_node.right, key)
      :eq -> curr_node
    end
  end

  defp do_delete(%Node{
    parent: nil,
    left: %Node{
      key: nil,
      color: :black,
    } = left,
    right: %Node{
      key: nil,
      color: :black,
    } = right,
  }), do: nil

  defp do_delete(%Node{
    parent: nil,
    left: %Node{
      key: left_key,
    } = left,
    right: %Node{
      key: nil,
      color: :black,
    } = right,
  }), do: %Node{left | parent: nil, color: :black}

  defp do_delete(%Node{
    parent: nil,
    right: %Node{
      key: right_key,
    } = right,
    left: %Node{
      key: nil,
      color: :black,
    } = left,
  }), do: %Node{right | parent: nil, color: :black}

  defp do_delete(%Node{
    parent: %Node{} = parent,
    left: %Node{
      key: nil,
      color: :black,
    } = left,
    right: %Node{
      key: nil,
      color: :black,
    } = right,
    key: _key,
  } = curr_node)
  when parent.left == curr_node do
    fix_parent(parent, :left, right)
  end

  defp do_delete(%Node{
    parent: %Node{
    } = parent,
    left: %Node{
      key: nil,
      color: :black,
    } = left,
    right: %Node{
      key: nil,
      color: :black,
    } = right,
    key: _key,
  } = curr_node)
  when parent.right == curr_node do
    fix_parent(parent, :right, left)
  end

  defp do_delete(%Node{
    parent: %Node{
    } = parent,
    left: %Node{
      key: _left_key,
    } = left,
    right: %Node{
      key: nil,
      color: :black,
    } = right,
  } = curr_node)
  when parent.right == curr_node do
    fix_parent(parent, :right, left)
  end

  defp do_delete(%Node{
    parent: %Node{
    } = parent,
    left: %Node{
      key: _left_key,
    } = left,
    right: %Node{
      key: nil,
      color: :black,
    } = right,
  } = curr_node)
  when parent.left == curr_node do
    fix_parent(parent, :left, left)
  end

  defp do_delete(%Node{
    parent: %Node{
    } = parent,
    right: %Node{
      key: _left_key,
    } = right,
    left: %Node{
      key: nil,
      color: :black,
    } = left,
  } = curr_node)
  when parent.right == curr_node do
    fix_parent(parent, :right, right)
  end

  defp do_delete(%Node{
    parent: %Node{
    } = parent,
    right: %Node{
      key: _right_key,
    } = right,
    left: %Node{
      key: nil,
      color: :black,
    } = left,
  } = curr_node)
  when parent.left == curr_node do
    fix_parent(parent, :left, right)
  end

  defp do_delete(%Node{
    left: %Node{
      key: left_key,
    } = left,
    right: %Node{
      key: right_key,
    } = right,
    key: curr_key,
    color: curr_color,
  } = curr_node) do
    {min_node, min_key} = find_min(right)
    case min_node.color do
      :red ->
        new_right = do_delete(min_node)
        %Node{curr_node | key: min_key, right: new_right}
      :black ->
        delete_fixup(min_node.right)
        %Node{curr_node | key: min_key}
    end
  end

  defp find_min(%Node{key: min_key} = curr_node) do
    case curr_node.left do
      %Node{} = left_node ->
        find_min(left_node)
      nil ->
        {curr_node, min_key}
    end
  end

  @spec filter(tree::RbTree.t(), fun :: (Comparable.t() -> boolean())) :: RbTree.t()
  def filter(tree, fun), do: %RbTree{root: filter_node(tree.root, fun, new())}

  defp filter_node(nil, _fun, acc), do: acc
  defp filter_node(%Node{} = node, fun, acc) do
    acc = filter_node(node.left, fun, acc)
    acc = if fun.(node.key) do
      insert(acc, node.key, node.value).root
    else
      acc
    end
    filter_node(node.right, fun, acc)
  end

  @spec map(set::RbTree.t(), fun :: (Comparable.t() -> Comparable.t())) :: RbTree.t()
  def map(tree, fun), do: %RbTree{root: map_node(tree.root, fun, new())}

  defp map_node(nil, _fun, acc), do: acc
  defp map_node(%Node{} = node, fun, acc) do
    acc = map_node(node.left, fun, acc)
    acc = insert(acc, node.key, fun.(node.value)).root
    map_node(node.right, fun, acc)
  end

  def to_list(nil, acc), do: acc
  def to_list(%Node{} =  node, acc) do
    if node.left != nil do
      acc = to_list(node.left, acc)
    end
    if node.right != nil do
      acc = to_list(node.right, acc)
    end
    [{node.key, node.value} | acc]
  end

  @spec get(set :: RbTree.t(), key :: Comparable.t()) :: {:ok, Comparable.t()} | {:none, nil}
  def get(%RbTree{root: nil}, _key), do: {:none, nil}
  def get(%RbTree{root: curr_node}, key) do
    case Comparable.compare(key, curr_node.key) do
      :lt -> get(%RbTree{root: curr_node.left}, key)
      :gt -> get(%RbTree{root: curr_node.right}, key)
      :eq -> {:ok, curr_node.value}
    end
  end

  @spec get_first(tree :: RbTree.t()) :: {:ok, {Comparable.t(), Any}} | {:none, {nil, nil}}
  def get_first(%RbTree{root: curr_node}) do
    do_get_first(curr_node)
  end

  defp do_get_first(nil), do: {:none, {nil, nil}}

  defp do_get_first(%Node{left: left_node} = curr_node) do
    if left_node != nil do
      do_get_first(left_node)
    else
      if curr_node.key != nil do
        {:ok, {curr_node.key, curr_node.value}}
      else
        {:none, {nil, nil}}
      end
    end
  end

  @spec equal?(first::RbTree.t(), second::RbTree.t()) :: boolean()
  def equal?(%RbTree{root: first_root} = first, %RbTree{root: second_root} = second) do
    {res1, {first_key, first_value}} = get_first(first)
    {res2, {second_key, second_value}} = get_first(second)
    cond do
      res1 == :none and res2 == :none ->
        true

      res1 == :none or res2 == :none ->
        false

      true ->
        case Comparable.compare(first_key, second_key) do
          :eq ->
            if first_value == second_value do
              new_first = delete(first, first_key)
              new_second = delete(second, second_key)
              equal?(new_first, new_second)
            else
              false
            end

          _another ->
            false
        end
    end
  end

  @spec fold_keyl(tree::RbTree.t(), acc :: Any, func :: (acc :: Any, x :: Comparable.t() -> acc :: Any)) :: Any
  def fold_keyl(%RbTree{root: root}, acc, func) do
    fold_keyl_node(root, acc, func)
  end

  defp fold_keyl_node(%Node{key: nil}, acc, _func), do: acc

  defp fold_keyl_node(%Node{} = curr_node, acc, func) do
    acc = fold_keyl_node(curr_node.left, acc, func)
    acc = func.(acc, curr_node.key)
    fold_keyl_node(curr_node.right, acc, func)
  end

  @spec fold_keyr(tree::RbTree.t(), acc :: Any, func :: (acc :: Any, x :: Comparable.t() -> acc :: Any)) :: Any
  def fold_keyr(%RbTree{root: root}, acc, func) do
    fold_keyr_node(root, acc, func)
  end

  defp fold_keyr_node(%Node{key: nil}, acc, _func), do: acc

  defp fold_keyr_node(%Node{} = curr_node, acc, func) do
    acc = fold_keyr_node(curr_node.right, acc, func)
    acc = func.(acc, curr_node.key)
    fold_keyr_node(curr_node.left, acc, func)
  end

  @spec fold_valuel(tree::RbTree.t(), acc :: Any, func :: (acc :: Any, x :: Any -> acc :: Any)) :: Any
  def fold_valuel(%RbTree{root: root}, acc, func) do
    fold_valuel_node(root, acc, func)
  end

  defp fold_valuel_node(%Node{key: nil}, acc, _func), do: acc

  defp fold_valuel_node(%Node{key: _key, value: value} = curr_node, acc, func) do
    acc = fold_valuel_node(curr_node.left, acc, func)
    acc = func.(acc, value)
    fold_valuel_node(curr_node.right, acc, func)
  end

  @spec fold_valuer(tree::RbTree.t(), acc :: Any, func :: (acc :: Any, x :: Any -> acc :: Any)) :: Any
  def fold_valuer(%RbTree{root: root}, acc, func) do
    fold_valuer_node(root, acc, func)
  end

  defp fold_valuer_node(%Node{key: nil}, acc, _func), do: acc

  defp fold_valuer_node(%Node{key: _key, value: value} = curr_node, acc, func) do
    acc = fold_valuer_node(curr_node.right, acc, func)
    acc = func.(acc, value)
    fold_valuer_node(curr_node.left, acc, func)
  end

  @spec insert_list(tree :: RbTree.t(), list :: list({Comparable.t(), Any})) :: RbTree.t()
  def insert_list(tree, [{key_head, value_head} | tail]) do
    new_tree = insert(tree, key_head, value_head)
    insert_list(new_tree, tail)
  end

  def insert_list(tree, []), do: tree

  defimpl Monoid do
    @spec empty(Any) :: RbTree.t()
    def empty(_), do: RbTree.new()

    @spec combine(tree1::RbTree.t(), tree2::RbTree.t())::RbTree.t()
    def combine(tree1, tree2) do
      RbTree.insert_list(tree1, RbTree.to_list(tree2.root, []))
    end
  end

  defimpl Collectable do
    @spec into(RbTree.t()) :: {RbTree.t(), (any(), :done | :halt | {any(), any()} -> any())}
    def into(%RbTree{} = tree) do
      collector_fun = fn
      curr_tree, {:cont, {key, value}} ->
        RbTree.insert(curr_tree, key, value)

      curr_tree, :done ->
        curr_tree

      _curr_tree, :halt ->
        :ok
    end
    initial_tree = tree
      {initial_tree, collector_fun}
    end
  end
end
