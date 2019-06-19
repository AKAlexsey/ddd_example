defmodule CtiKaltura.PaginationView do
  use CtiKalturaWeb, :view

  @arrow_up "&#x2B06;"
  @arrow_down "&#x2B07;"
  @no_ordering_arrow " "

  def put_pagination(pagination_meta, put_data) do
    pagination_meta
    |> Map.delete(:total_elements)
    |> Map.merge(put_data)
  end

  def get_page(pagination_meta), do: Map.get(pagination_meta, :page)

  def previous_page(pagination_meta) do
    if(first_page?(pagination_meta), do: 1, else: get_page(pagination_meta) - 1)
  end

  def previous_page_class(pagination_meta) do
    if(first_page?(pagination_meta), do: "disabled", else: "")
  end

  defp first_page?(pagination_meta) do
    get_page(pagination_meta) <= 1
  end

  def next_page(pagination_meta) do
    if(
      last_page?(pagination_meta),
      do: get_page(pagination_meta),
      else: get_page(pagination_meta) + 1
    )
  end

  def next_page_class(pagination_meta) do
    if(last_page?(pagination_meta), do: "disabled", else: "")
  end

  defp last_page?(pagination_meta) do
    get_page(pagination_meta) >= maximum_page(pagination_meta)
  end

  defp maximum_page(pagination_meta) do
    per_page = Map.get(pagination_meta, :per_page)
    total_elements = Map.get(pagination_meta, :total_elements)

    Float.ceil(total_elements / per_page)
    |> Kernel.trunc()
  end

  def pages_list(pagination_meta) do
    current_page = get_page(pagination_meta)
    max_page = maximum_page(pagination_meta)

    if max_page > 0 do
      1..max_page
      |> Enum.map(fn page ->
        if(page == current_page, do: {page, "active"}, else: {page, ""})
      end)
    else
      []
    end
  end

  def ordering_link(pagination_meta, field, path_function) do
    pagination_meta
    |> get_direction(field)
    |> make_order_path(pagination_meta, field, path_function)
  end

  defp make_order_path(direction, pagination_meta, field, path_function) do
    direction
    |> make_ordering_link_params(pagination_meta, field)
    |> path_function.()
  end

  defp make_ordering_link_params(direction, pagination_meta, field) do
    case direction do
      "asc" ->
        put_pagination(pagination_meta, %{order_by: "desc:#{field}"})

      _ ->
        put_pagination(pagination_meta, %{order_by: "asc:#{field}"})
    end
  end

  def ordering_label(pagination_meta, field, label) do
    pagination_meta
    |> get_direction(field)
    |> make_order_label(label)
  end

  defp get_direction(%{order_by: order_by}, field) do
    case String.split(order_by, ",") do
      [only_element] ->
        field_order_direction(only_element, "#{field}")

      orderings_list when length(orderings_list) > 1 ->
        orderings_list
        |> Enum.map(fn order_string -> field_order_direction(order_string, "#{field}") end)
        |> Enum.find(fn arrow -> not is_nil(arrow) end)

      _ ->
        nil
    end
  end

  defp get_direction(_pagination_meta, _field), do: nil

  defp make_order_label("asc", label), do: raw("#{@arrow_down} #{label}")
  defp make_order_label("desc", label), do: raw("#{@arrow_up} #{label}")
  defp make_order_label(_, label), do: raw("#{@no_ordering_arrow} #{label}")

  defp field_order_direction(order_string, field) do
    case String.split(order_string, ":") do
      ["asc", ^field] -> "asc"
      ["desc", ^field] -> "desc"
      _ -> nil
    end
  end
end
