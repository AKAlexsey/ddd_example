defmodule CtiKaltura.ContentPagination do
  @moduledoc """
  Содержит функции для пагинации сущностей, принадлежащих к скоупу Content.
  """

  alias CtiKaltura.Content.Program
  alias CtiKaltura.Repo

  @permitted_params %{
    Program => [:order_by, :page, :per_page, :filter_by]
  }
  @default_per_page Application.get_env(:cti_kaltura, :pagination)[:default_per_page]

  import Ecto.Query

  @doc """
  Для программ позволяет осуществлять:

  1. Пагинацию;
  2. Сортировку по выбранному полю;
  3. Фильтрацию по выбранному каналу.
  """
  @spec programs_pagination(map, list) :: {list, map}
  def programs_pagination(params \\ %{}, preload \\ []) do
    params
    |> normalize_params(Program)
    |> build_query(Program, preload)
    |> perform_query()
  end

  defp build_query(pagination_params, model, preload) do
    {from(m in model), %{}}
    |> add_sorting(pagination_params)
    |> add_filtering(pagination_params)
    |> add_pagination(pagination_params)
    |> add_preloading(preload)
  end

  defp add_sorting({query, pagination_meta}, %{order_by: order_by}) do
    case prepare_ordering_argument(order_by) do
      nil ->
        {query, pagination_meta}

      {query_argument, metadata_order_by} ->
        {
          order_by(query, ^query_argument),
          Map.put(pagination_meta, :order_by, metadata_order_by)
        }
    end
  end

  defp add_sorting({query, pagination_meta}, _params), do: {query, pagination_meta}

  defp prepare_ordering_argument(order_by) when is_binary(order_by) do
    case String.split(order_by, ",") do
      orderings when length(orderings) > 1 ->
        orderings
        |> Enum.map(fn ordering ->
          [order, field] = String.split(ordering, ":")
          {String.to_atom(order), String.to_atom(field)}
        end)
        |> prepare_ordering_argument()

      orderings when length(orderings) == 1 ->
        case String.split(hd(orderings), ":") do
          [order, field] ->
            prepare_ordering_argument([{String.to_atom(order), String.to_atom(field)}])

          _ ->
            nil
        end

      _ ->
        nil
    end
  end

  defp prepare_ordering_argument(order_by) when is_list(order_by) do
    {
      Enum.filter(order_by, fn {order, _field} -> order in [:asc, :desc] end),
      Enum.join(Enum.map(order_by, fn {order, field} -> "#{order}:#{field}" end), ",")
    }
  end

  defp add_pagination({query, pagination_meta}, %{page: page, per_page: per_page})
       when page > 0 do
    integer_page = string_to_integer(page)
    integer_per_page = string_to_integer(per_page)

    query
    |> offset(^(integer_per_page * (integer_page - 1)))
    |> limit(^integer_per_page)
    |> (fn result_query ->
          {
            result_query,
            Map.merge(pagination_meta, %{
              page: integer_page,
              per_page: integer_per_page,
              total_elements: Repo.aggregate(query, :count, :id)
            })
          }
        end).()
  end

  defp add_pagination({query, pagination_meta}, %{page: page}) do
    add_pagination({query, pagination_meta}, %{page: page, per_page: @default_per_page})
  end

  defp add_pagination({query, pagination_meta}, %{per_page: per_page}) do
    add_pagination({query, pagination_meta}, %{page: 1, per_page: per_page})
  end

  defp add_pagination({query, pagination_meta}, _params) do
    add_pagination({query, pagination_meta}, %{page: 1})
  end

  defp add_filtering({query, pagination_meta}, %{filter_by: filter_by}) do
    case prepare_filtering_argument(filter_by) do
      nil ->
        {query, pagination_meta}

      filtering_argument ->
        {
          where(query, ^filtering_argument),
          Map.put(pagination_meta, :filter_by, filter_by)
        }
    end
  end

  defp add_filtering({query, pagination_meta}, _params), do: {query, pagination_meta}

  defp prepare_filtering_argument(filter_by) when is_binary(filter_by) do
    case String.split(filter_by, ":") do
      [field, value] ->
        [{String.to_atom(field), value}]

      _ ->
        nil
    end
  end

  defp prepare_filtering_argument(filter_by) when is_list(filter_by), do: filter_by
  defp prepare_filtering_argument(_), do: nil

  defp add_preloading({query, pagination_meta}, preload) do
    {preload(query, ^preload), pagination_meta}
  end

  defp perform_query({query, pagination_meta}) do
    {Repo.all(query), pagination_meta}
  end

  @doc """
  Принимает
  """
  @spec normalize_params(map, atom) :: map
  def normalize_params(params, model) when is_map(params) do
    params
    |> Enum.map(fn {key, value} -> {normalize_key(key), value} end)
    |> Enum.filter(&permitted_params_for(&1, model))
    |> Enum.into(%{})
  end

  defp normalize_key(key) when is_atom(key), do: key
  defp normalize_key(key) when is_binary(key), do: String.to_atom(key)

  defp permitted_params_for({key, _value}, model) do
    case Map.get(@permitted_params, model) do
      nil ->
        raise RuntimeError,
          message:
            "No configuration for #{inspect(model)}. Please define it inside @permitted_params module variable"

      model_permitted_params_list ->
        key in model_permitted_params_list
    end
  end

  defp string_to_integer(str) when is_binary(str) do
    {integer, ""} = Integer.parse(str)
    integer
  end

  defp string_to_integer(number), do: number
end
