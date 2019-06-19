defmodule CtiKaltura.ContentPaginationTest do
  use CtiKaltura.DataCase

  alias CtiKaltura.Content.Program
  alias CtiKaltura.ContentPagination

  describe "#programs_pagination" do
    test ":order_by param working #1" do
      {:ok, program1} = Factory.insert(:program, %{name: "name5", epg_id: "000000002"})
      {:ok, program2} = Factory.insert(:program, %{name: "name4", epg_id: "000000003"})
      {:ok, program3} = Factory.insert(:program, %{name: "name3", epg_id: "000000001"})
      {:ok, program4} = Factory.insert(:program, %{name: "name2", epg_id: "000000005"})
      {:ok, program5} = Factory.insert(:program, %{name: "name1", epg_id: "000000004"})

      assert get_ids(
               {[program5, program4, program3, program2, program1],
                %{order_by: "asc:name", page: 1, per_page: 25, total_elements: 5}}
             ) == get_ids(ContentPagination.programs_pagination(%{"order_by" => "asc:name"}))

      assert get_ids(
               {[program1, program2, program3, program4, program5],
                %{order_by: "desc:name", page: 1, per_page: 25, total_elements: 5}}
             ) == get_ids(ContentPagination.programs_pagination(%{order_by: [desc: :name]}))

      assert get_ids(
               {[program3, program1, program2, program5, program4],
                %{order_by: "asc:epg_id", page: 1, per_page: 25, total_elements: 5}}
             ) == get_ids(ContentPagination.programs_pagination(%{order_by: "asc:epg_id"}))

      assert get_ids(
               {[program4, program5, program2, program1, program3],
                %{order_by: "desc:epg_id", page: 1, per_page: 25, total_elements: 5}}
             ) == get_ids(ContentPagination.programs_pagination(%{"order_by" => [desc: :epg_id]}))
    end

    test ":order_by param working #2 several orderings" do
      {:ok, program1} = Factory.insert(:program, %{name: "name1", epg_id: "000000002"})
      {:ok, program2} = Factory.insert(:program, %{name: "name1", epg_id: "000000003"})
      {:ok, program3} = Factory.insert(:program, %{name: "name1", epg_id: "000000001"})
      {:ok, program4} = Factory.insert(:program, %{name: "name2", epg_id: "000000005"})
      {:ok, program5} = Factory.insert(:program, %{name: "name2", epg_id: "000000004"})

      assert get_ids(
               {[program2, program1, program3, program4, program5],
                %{order_by: "asc:name,desc:epg_id", page: 1, per_page: 25, total_elements: 5}}
             ) ==
               get_ids(
                 ContentPagination.programs_pagination(%{
                   "order_by" => [asc: :name, desc: :epg_id]
                 })
               )

      assert get_ids(
               {[program4, program5, program2, program1, program3],
                %{
                  order_by: "desc:name,desc:epg_id",
                  page: 1,
                  per_page: 25,
                  total_elements: 5
                }}
             ) ==
               get_ids(
                 ContentPagination.programs_pagination(%{order_by: "desc:name,desc:epg_id"})
               )

      assert get_ids(
               {[program3, program1, program2, program5, program4],
                %{order_by: "asc:name,asc:epg_id", page: 1, per_page: 25, total_elements: 5}}
             ) ==
               get_ids(
                 ContentPagination.programs_pagination(%{order_by: [asc: :name, asc: :epg_id]})
               )

      assert get_ids(
               {[program3, program1, program2, program5, program4],
                %{order_by: "asc:epg_id,asc:name", page: 1, per_page: 25, total_elements: 5}}
             ) ==
               get_ids(
                 ContentPagination.programs_pagination(%{"order_by" => "asc:epg_id,asc:name"})
               )

      assert get_ids(
               {[program5, program4, program3, program1, program2],
                %{order_by: "desc:name,asc:epg_id", page: 1, per_page: 25, total_elements: 5}}
             ) ==
               get_ids(
                 ContentPagination.programs_pagination(%{
                   "order_by" => [desc: :name, asc: :epg_id]
                 })
               )
    end

    test ":order_by does not fail in case of wrong param" do
      Factory.insert(:program, %{name: "name1", epg_id: "000000002"})
      Factory.insert(:program, %{name: "name1", epg_id: "000000003"})
      Factory.insert(:program, %{name: "name1", epg_id: "000000001"})
      Factory.insert(:program, %{name: "name2", epg_id: "000000005"})
      Factory.insert(:program, %{name: "name2", epg_id: "000000004"})

      assert {_, %{order_by: "ascc:name", page: 1, per_page: 25, total_elements: 5}} =
               ContentPagination.programs_pagination(%{"order_by" => [ascc: :name]})
    end

    test ":page, :per_page params working" do
      {:ok, program1} = Factory.insert(:program)
      {:ok, program2} = Factory.insert(:program)
      {:ok, program3} = Factory.insert(:program)
      {:ok, program4} = Factory.insert(:program)
      {:ok, program5} = Factory.insert(:program)
      {:ok, program6} = Factory.insert(:program)
      {:ok, program7} = Factory.insert(:program)
      {:ok, program8} = Factory.insert(:program)
      {:ok, program9} = Factory.insert(:program)
      {:ok, program10} = Factory.insert(:program)

      assert get_ids(
               {[
                  program1,
                  program2,
                  program3,
                  program4,
                  program5,
                  program6,
                  program7,
                  program8,
                  program9,
                  program10
                ], %{order_by: "asc:id", page: 1, per_page: 10, total_elements: 10}}
             ) ==
               get_ids(
                 ContentPagination.programs_pagination(%{
                   per_page: 10,
                   page: 1,
                   order_by: [asc: :id]
                 })
               )

      assert get_ids({[], %{order_by: "asc:id", page: 2, per_page: 10, total_elements: 10}}) ==
               get_ids(
                 ContentPagination.programs_pagination(%{
                   per_page: 10,
                   page: 2,
                   order_by: [asc: :id]
                 })
               )

      assert get_ids(
               {[program1, program2, program3],
                %{order_by: "asc:id", page: 1, per_page: 3, total_elements: 10}}
             ) ==
               get_ids(
                 ContentPagination.programs_pagination(%{
                   per_page: 3,
                   page: 1,
                   order_by: [asc: :id]
                 })
               )

      assert get_ids(
               {[program10], %{order_by: "asc:id", page: 4, per_page: 3, total_elements: 10}}
             ) ==
               get_ids(
                 ContentPagination.programs_pagination(%{
                   per_page: 3,
                   page: 4,
                   order_by: [asc: :id]
                 })
               )

      assert get_ids(
               {[program6, program7, program8, program9, program10],
                %{order_by: "asc:id", page: 2, per_page: 5, total_elements: 10}}
             ) ==
               get_ids(
                 ContentPagination.programs_pagination(%{
                   per_page: 5,
                   page: 2,
                   order_by: [asc: :id]
                 })
               )

      assert get_ids(
               {[program1, program2, program3, program4, program5, program6, program7],
                %{order_by: "asc:id", page: 1, per_page: 7, total_elements: 10}}
             ) ==
               get_ids(
                 ContentPagination.programs_pagination(%{
                   per_page: 7,
                   page: 1,
                   order_by: [asc: :id]
                 })
               )

      assert get_ids(
               {[program8, program9, program10],
                %{order_by: "asc:id", page: 2, per_page: 7, total_elements: 10}}
             ) ==
               get_ids(
                 ContentPagination.programs_pagination(%{
                   per_page: 7,
                   page: 2,
                   order_by: [asc: :id]
                 })
               )
    end

    test "Using only :page will use default :per_page param (25)" do
      {:ok, program1} = Factory.insert(:program)
      {:ok, program2} = Factory.insert(:program)
      {:ok, program3} = Factory.insert(:program)
      {:ok, program4} = Factory.insert(:program)
      {:ok, program5} = Factory.insert(:program)
      {:ok, program6} = Factory.insert(:program)
      {:ok, program7} = Factory.insert(:program)
      {:ok, program8} = Factory.insert(:program)
      {:ok, program9} = Factory.insert(:program)
      {:ok, program10} = Factory.insert(:program)
      {:ok, program11} = Factory.insert(:program)
      {:ok, program12} = Factory.insert(:program)
      {:ok, program13} = Factory.insert(:program)
      {:ok, program14} = Factory.insert(:program)
      {:ok, program15} = Factory.insert(:program)
      {:ok, program16} = Factory.insert(:program)
      {:ok, program17} = Factory.insert(:program)
      {:ok, program18} = Factory.insert(:program)
      {:ok, program19} = Factory.insert(:program)
      {:ok, program20} = Factory.insert(:program)
      {:ok, program21} = Factory.insert(:program)
      {:ok, program22} = Factory.insert(:program)
      {:ok, program23} = Factory.insert(:program)
      {:ok, program24} = Factory.insert(:program)
      {:ok, program25} = Factory.insert(:program)
      {:ok, program26} = Factory.insert(:program)

      assert get_ids(
               {[
                  program1,
                  program2,
                  program3,
                  program4,
                  program5,
                  program6,
                  program7,
                  program8,
                  program9,
                  program10,
                  program11,
                  program12,
                  program13,
                  program14,
                  program15,
                  program16,
                  program17,
                  program18,
                  program19,
                  program20,
                  program21,
                  program22,
                  program23,
                  program24,
                  program25
                ], %{order_by: "asc:id", page: 1, per_page: 25, total_elements: 26}}
             ) == get_ids(ContentPagination.programs_pagination(%{page: 1, order_by: [asc: :id]}))

      assert get_ids(
               {[program26], %{order_by: "asc:id", page: 2, per_page: 25, total_elements: 26}}
             ) == get_ids(ContentPagination.programs_pagination(%{page: 2, order_by: [asc: :id]}))
    end

    test "Using only :per_page will sets page to 1" do
      {:ok, program1} = Factory.insert(:program)
      {:ok, program2} = Factory.insert(:program)
      {:ok, program3} = Factory.insert(:program)
      {:ok, program4} = Factory.insert(:program)
      {:ok, program5} = Factory.insert(:program)
      {:ok, program6} = Factory.insert(:program)
      {:ok, program7} = Factory.insert(:program)
      {:ok, program8} = Factory.insert(:program)
      {:ok, program9} = Factory.insert(:program)
      {:ok, program10} = Factory.insert(:program)

      assert get_ids(
               {[
                  program1,
                  program2,
                  program3,
                  program4,
                  program5
                ], %{order_by: "asc:id", page: 1, per_page: 5, total_elements: 10}}
             ) ==
               get_ids(
                 ContentPagination.programs_pagination(%{per_page: 5, order_by: [asc: :id]})
               )

      assert get_ids(
               {[
                  program10,
                  program9,
                  program8,
                  program7,
                  program6
                ], %{order_by: "desc:id", page: 1, per_page: 5, total_elements: 10}}
             ) ==
               get_ids(
                 ContentPagination.programs_pagination(%{per_page: 5, order_by: [desc: :id]})
               )
    end

    test ":filter_by param working" do
      {:ok, linear_channel1} = Factory.insert(:linear_channel)
      {:ok, program1} = Factory.insert(:program, %{linear_channel_id: linear_channel1.id})
      {:ok, linear_channel2} = Factory.insert(:linear_channel)
      {:ok, program2} = Factory.insert(:program, %{linear_channel_id: linear_channel2.id})

      assert get_ids(
               {[program1, program2],
                %{order_by: "asc:id", page: 1, per_page: 25, total_elements: 2}}
             ) == get_ids(ContentPagination.programs_pagination(%{order_by: [asc: :id]}))

      assert get_ids(
               {[program1],
                %{
                  order_by: "asc:id",
                  filter_by: "linear_channel_id:#{linear_channel1.id}",
                  page: 1,
                  per_page: 25,
                  total_elements: 1
                }}
             ) ==
               get_ids(
                 ContentPagination.programs_pagination(%{
                   order_by: "asc:id",
                   filter_by: "linear_channel_id:#{linear_channel1.id}"
                 })
               )

      assert get_ids(
               {[program2],
                %{
                  order_by: "asc:id",
                  filter_by: "linear_channel_id:#{linear_channel2.id}",
                  page: 1,
                  per_page: 25,
                  total_elements: 1
                }}
             ) ==
               get_ids(
                 ContentPagination.programs_pagination(%{
                   order_by: [asc: :id],
                   filter_by: "linear_channel_id:#{linear_channel2.id}"
                 })
               )

      assert get_ids(
               {[],
                %{
                  order_by: "asc:id",
                  filter_by: [linear_channel_id: 777],
                  page: 1,
                  per_page: 25,
                  total_elements: 0
                }}
             ) ==
               get_ids(
                 ContentPagination.programs_pagination(%{
                   order_by: [asc: :id],
                   filter_by: [linear_channel_id: 777]
                 })
               )

      assert get_ids(
               {[linear_channel1],
                %{
                  order_by: "asc:id",
                  filter_by: [linear_channel_id: linear_channel1.id],
                  page: 1,
                  per_page: 25,
                  total_elements: 1
                }}
             ) ==
               get_ids(
                 get_collection_association(
                   ContentPagination.programs_pagination(
                     %{
                       order_by: [asc: :id],
                       filter_by: [linear_channel_id: linear_channel1.id]
                     },
                     [:linear_channel]
                   ),
                   :linear_channel
                 )
               )
    end

    test ":preload preloads necessary models" do
      {:ok, linear_channel} = Factory.insert(:linear_channel)
      {:ok, program} = Factory.insert(:program, %{linear_channel_id: linear_channel.id})
      {:ok, program_record} = Factory.insert(:program_record, %{program_id: program.id})

      assert {[%Ecto.Association.NotLoaded{}], %{page: 1, per_page: 25, total_elements: 1}} =
               get_collection_association(
                 ContentPagination.programs_pagination(%{}, []),
                 :program_records
               )

      assert {[%Ecto.Association.NotLoaded{}], %{page: 1, per_page: 25, total_elements: 1}} =
               get_collection_association(
                 ContentPagination.programs_pagination(%{}, []),
                 :linear_channel
               )

      assert {[[^program_record]], %{page: 1, per_page: 25, total_elements: 1}} =
               get_collection_association(
                 ContentPagination.programs_pagination(%{}, [:program_records]),
                 :program_records
               )

      assert {[%Ecto.Association.NotLoaded{}], %{page: 1, per_page: 25, total_elements: 1}} =
               get_collection_association(
                 ContentPagination.programs_pagination(%{}, [:program_records]),
                 :linear_channel
               )

      assert {[%Ecto.Association.NotLoaded{}], %{page: 1, per_page: 25, total_elements: 1}} =
               get_collection_association(
                 ContentPagination.programs_pagination(%{}, [:linear_channel]),
                 :program_records
               )

      assert get_ids({[linear_channel], %{page: 1, per_page: 25, total_elements: 1}}) ==
               get_ids(
                 get_collection_association(
                   ContentPagination.programs_pagination(%{}, [:linear_channel]),
                   :linear_channel
                 )
               )
    end
  end

  describe "#normalize_params" do
    test "Move String keys to atoms" do
      assert %{page: 1, per_page: "1"} ==
               ContentPagination.normalize_params(%{page: 1, per_page: "1"}, Program)
    end

    test "Does not change atom keys" do
      assert %{page: 1, per_page: "1"} ==
               ContentPagination.normalize_params(%{"page" => 1, "per_page" => "1"}, Program)
    end

    test "Filter param keys those does not belong to @allowed_params for given model" do
      assert %{
               page: 1,
               per_page: "1",
               order_by: :id,
               filter_by: "linear_channel_id:34"
             } ==
               ContentPagination.normalize_params(
                 %{
                   "page" => 1,
                   "per_page" => "1",
                   "order_by" => :id,
                   "filter_by" => "linear_channel_id:34",
                   "wrong_param" => :param
                 },
                 Program
               )
    end

    test "Raise error if params is not map" do
      assert_raise(FunctionClauseError, fn ->
        ContentPagination.normalize_params([page: 1, per_page: "1"], Program)
      end)
    end

    test "Raise error if model does not have configuration" do
      assert_raise(RuntimeError, fn ->
        ContentPagination.normalize_params(%{page: 1, per_page: "1"}, ContentPagination)
      end)
    end
  end

  def get_ids({collection, pagination_meta}), do: {Enum.map(collection, & &1.id), pagination_meta}

  def get_collection_association({collection, pagination_meta}, association) do
    {Enum.map(collection, &Map.get(&1, association)), pagination_meta}
  end
end
