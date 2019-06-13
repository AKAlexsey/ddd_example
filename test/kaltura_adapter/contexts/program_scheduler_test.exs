defmodule CtiKaltura.ProgramScheduling.ProgramSchedulerTest do
  use CtiKaltura.ModelCase, async: false

  alias CtiKaltura.{Content, Repo}
  alias CtiKaltura.Content.{LinearChannel, Program}
  alias CtiKaltura.ProgramScheduling.{ProgramScheduler, Time}

  describe "#perform" do
    setup do
      epg_id = "000000014"

      {:ok, server_group} = Factory.insert(:server_group)

      {:ok, linear_channel} =
        Factory.insert(:linear_channel, %{
          epg_id: epg_id,
          dvr_enabled: true,
          server_group_id: server_group.id
        })

      program_data = %{
        linear_channel: %{epg_id: epg_id},
        programs: [
          %{
            end_datetime: "20190406010000",
            epg_id: "30190406003000",
            name: "Click",
            start_datetime: "20190406003000"
          },
          %{
            end_datetime: "20190406013000",
            epg_id: "30190406010000",
            name: "BBC News Special",
            start_datetime: "20190406010000"
          },
          %{
            end_datetime: "20190406020000",
            epg_id: "30190406013000",
            name: "TBA",
            start_datetime: "20190406013000"
          }
        ]
      }

      program_epg_ids = ["30190406003000", "30190406010000", "30190406013000"]

      {:ok,
       program_data: program_data,
       linear_channel: linear_channel,
       program_epg_ids: program_epg_ids}
    end

    test "Create programs by given data", %{
      program_data: program_data,
      program_epg_ids: program_epg_ids
    } do
      before_program_count = Repo.aggregate(Program, :count, :id)
      assert [] == Repo.all(from(p in Program, where: p.epg_id in ^program_epg_ids))

      assert :ok == ProgramScheduler.perform(program_data)

      assert before_program_count + 3 == Repo.aggregate(Program, :count, :id)

      assert 3 =
               Repo.aggregate(
                 from(p in Program, where: p.epg_id in ^program_epg_ids),
                 :count,
                 :id
               )
    end

    test "Does not create programs if given params contains empty list", %{
      linear_channel: linear_channel
    } do
      before_program_count = Repo.aggregate(Program, :count, :id)

      assert :ok ==
               ProgramScheduler.perform(%{
                 linear_channel: %{epg_id: linear_channel.epg_id},
                 programs: []
               })

      assert before_program_count == Repo.aggregate(Program, :count, :id)
    end

    test "Remove old programs if their time cross given programs time", %{
      program_data: program_data,
      linear_channel: linear_channel,
      program_epg_ids: program_epg_ids
    } do
      {:ok, program1} =
        Factory.insert(:program, %{
          start_datetime: Time.time_to_utc("20190406003000"),
          end_datetime: Time.time_to_utc("20190406010000"),
          name: "Click Old",
          linear_channel_id: linear_channel.id
        })

      {:ok, program2} =
        Factory.insert(:program, %{
          start_datetime: Time.time_to_utc("20190406010000"),
          end_datetime: Time.time_to_utc("20190406013000"),
          name: "BBC News Special Old",
          linear_channel_id: linear_channel.id
        })

      {:ok, program3} =
        Factory.insert(:program, %{
          start_datetime: Time.time_to_utc("20190406013000"),
          end_datetime: Time.time_to_utc("20190406020000"),
          name: "TBA Old",
          linear_channel_id: linear_channel.id
        })

      :timer.sleep(100)

      before_program_count = Repo.aggregate(Program, :count, :id)
      assert [] == Repo.all(from(p in Program, where: p.epg_id in ^program_epg_ids))

      assert :ok == ProgramScheduler.perform(program_data)

      assert before_program_count == Repo.aggregate(Program, :count, :id)

      assert 3 =
               Repo.aggregate(
                 from(p in Program, where: p.epg_id in ^program_epg_ids),
                 :count,
                 :id
               )

      assert is_nil(Repo.get(Program, program1.id))
      assert is_nil(Repo.get(Program, program2.id))
      assert is_nil(Repo.get(Program, program3.id))
    end

    test "Return error if linear channel does not exist", %{
      program_data: program_data,
      linear_channel: linear_channel
    } do
      Content.delete_linear_channel(linear_channel)

      assert {:error, :linear_channel_does_not_exist} == ProgramScheduler.perform(program_data)
    end

    test "Return error if LinearChannel dvr_enabled if false", %{
      program_data: program_data,
      linear_channel: linear_channel
    } do
      linear_channel
      |> LinearChannel.changeset(%{dvr_enabled: false})
      |> Repo.update!()

      assert {:error, :linear_channel_dvr_does_not_enabled} ==
               ProgramScheduler.perform(program_data)
    end
  end

  describe "#clean_obsolete" do
    test "Remove obsolete Programs" do
      now = NaiveDateTime.utc_now()

      Factory.insert(:program, %{start_datetime: NaiveDateTime.add(now, -3500, :seconds)})

      {:ok, program1} =
        Factory.insert(:program, %{start_datetime: NaiveDateTime.add(now, -3700, :seconds)})

      {:ok, program2} =
        Factory.insert(:program, %{start_datetime: NaiveDateTime.add(now, -7_300, :seconds)})

      {:ok, program3} =
        Factory.insert(:program, %{start_datetime: NaiveDateTime.add(now, -11_900, :seconds)})

      {:ok, program4} =
        Factory.insert(:program, %{start_datetime: NaiveDateTime.add(now, -14_500, :seconds)})

      assert [program4.id] == get_ids(ProgramScheduler.clean_obsolete(4))
      assert [program3.id] == get_ids(ProgramScheduler.clean_obsolete(3))
      assert [program2.id] == get_ids(ProgramScheduler.clean_obsolete(2))
      assert [program1.id] == get_ids(ProgramScheduler.clean_obsolete(1))
    end

    test "Return {:ok, :no_programs} if there are no obsolete programs" do
      assert {:ok, :no_programs} = ProgramScheduler.clean_obsolete(1)
    end
  end

  def get_ids({:ok, %{removed_ids: collection}}), do: Enum.sort(collection)
end
