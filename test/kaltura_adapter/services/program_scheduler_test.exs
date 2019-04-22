defmodule CtiKaltura.ProgramScheduling.ProgramSchedulerTest do
  use CtiKaltura.ModelCase, async: false

  alias CtiKaltura.{Content, Repo}
  alias CtiKaltura.Content.Program
  alias CtiKaltura.ProgramScheduling.ProgramScheduler

  describe "#time_to_utc" do
    test "Return right datetime #1" do
      year = 2019
      month = 11
      day = 14
      hours = 12
      minutes = 12
      seconds = 12

      {:ok, standard} = NaiveDateTime.from_erl({{year, month, day}, {hours, minutes, seconds}})

      assert standard ==
               ProgramScheduler.time_to_utc("#{year}#{month}#{day}#{hours}#{minutes}#{seconds}")
    end

    test "Return right datetime #2" do
      year = 2008
      month = 4
      day = 14
      hours = 9
      minutes = 9
      seconds = 9

      {:ok, standard} = NaiveDateTime.from_erl({{year, month, day}, {hours, minutes, seconds}})

      assert standard ==
               ProgramScheduler.time_to_utc(
                 "#{year}0#{month}#{day}0#{hours}0#{minutes}0#{seconds}"
               )
    end
  end

  describe "#perform" do
    setup do
      epg_id = "000000014"

      {:ok, linear_channel} = Factory.insert(:linear_channel, %{epg_id: epg_id})

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

    test "Remove old programs if their time cross given programs time", %{
      program_data: program_data,
      linear_channel: linear_channel,
      program_epg_ids: program_epg_ids
    } do
      {:ok, program1} =
        Factory.insert(:program, %{
          start_datetime: ProgramScheduler.time_to_utc("20190406003000"),
          end_datetime: ProgramScheduler.time_to_utc("20190406010000"),
          name: "Click Old",
          linear_channel_id: linear_channel.id
        })

      {:ok, program2} =
        Factory.insert(:program, %{
          start_datetime: ProgramScheduler.time_to_utc("20190406010000"),
          end_datetime: ProgramScheduler.time_to_utc("20190406013000"),
          name: "BBC News Special Old",
          linear_channel_id: linear_channel.id
        })

      {:ok, program3} =
        Factory.insert(:program, %{
          start_datetime: ProgramScheduler.time_to_utc("20190406013000"),
          end_datetime: ProgramScheduler.time_to_utc("20190406020000"),
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
  end
end
