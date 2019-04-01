defmodule CtiKaltura.LayoutView do
  use CtiKalturaWeb, :view

  def html_decorate_collection(items) do
    items
    |> Enum.map(fn {name, _} -> "<span class=\"elem\">#{name}</span>" end)
    |> Enum.join(" ")
  end

  def to_select_collection(items, item_name_eval_fn) do
    items
    |> Enum.map(fn item -> {item_name_eval_fn.(item), item.id} end)
  end

  def to_plural(str) do
    s = to_string(str)
    "#{s}s"
  end

  def to_capitalize(str) do
    String.capitalize(to_string(str))
  end

  def to_plural_capitalize(str) do
    str
    |> to_plural
    |> to_capitalize
  end

  def render_for_show(meta, item) do
    ""
    |> render_for_show_by_field(meta, item)
    |> render_for_show_by_fn(meta, item)
  end

  def render_for_show_by_fn(meta, item) do
    render_for_show_by_fn("", meta, item)
  end

  def render_for_show_by_fn(str, meta, item) do
    str
    |> render_for_show_by_eval_fn(meta, item)
    |> render_for_show_by_eval_html_fn(meta, item)
  end

  defp render_for_show_by_field(str, meta, item) do
    if Map.has_key?(meta, :field) do
      Map.get(item, meta.field)
    else
      str
    end
  end

  defp render_for_show_by_eval_fn(str, meta, item) do
    if Map.has_key?(meta, :eval_fn) do
      meta.eval_fn.(item)
    else
      str
    end
  end

  defp render_for_show_by_eval_html_fn(str, meta, item) do
    if Map.has_key?(meta, :eval_html_fn) do
      raw(meta.eval_html_fn.(item))
    else
      str
    end
  end
end
