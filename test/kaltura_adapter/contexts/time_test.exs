defmodule CtiKaltura.ProgramScheduling.TimeTest do
  use CtiKaltura.ModelCase, async: false

  alias CtiKaltura.ProgramScheduling.Time
  import Mock

  describe "#time_to_utc" do
    test "Return right datetime #1" do
      year = 2019
      month = 11
      day = 14
      hours = 12
      minutes = 12
      seconds = 12

      {:ok, standard} = NaiveDateTime.from_erl({{year, month, day}, {hours, minutes, seconds}})

      assert standard == Time.time_to_utc("#{year}#{month}#{day}#{hours}#{minutes}#{seconds}")
    end

    test "Return right datetime #2" do
      year = 2008
      month = 4
      day = 14
      hours = 9
      minutes = 9
      seconds = 9

      {:ok, standard} = NaiveDateTime.from_erl({{year, month, day}, {hours, minutes, seconds}})

      assert standard == Time.time_to_utc("#{year}0#{month}#{day}0#{hours}0#{minutes}0#{seconds}")
    end
  end

  describe "#hours_ago" do
    test "Return time past in hours" do
      time = NaiveDateTime.utc_now()
      assert NaiveDateTime.add(time, -3_600, :seconds) == Time.hours_ago(1, time)
      assert NaiveDateTime.add(time, -7_200, :seconds) == Time.hours_ago(2, time)
      assert NaiveDateTime.add(time, -10_800, :seconds) == Time.hours_ago(3, time)
      assert NaiveDateTime.add(time, -36_000, :seconds) == Time.hours_ago(10, time)
    end

    test "Use NaiveDateTime.utc_now() if no second parameter" do
      time = NaiveDateTime.add(NaiveDateTime.utc_now(), -1200, :seconds)
      standard = NaiveDateTime.add(time, -3600, :seconds)

      with_mocks([{NaiveDateTime, [], [utc_now: fn -> time end, add: fn _, _, _ -> standard end]}]) do
        assert standard == Time.hours_ago(1)
      end
    end

    test "Raise error if hours less than zero" do
      time = NaiveDateTime.utc_now()

      assert_raise FunctionClauseError, fn ->
        Time.hours_ago(-1, time)
      end
    end

    test "Raise error if hours is not integer" do
      time = NaiveDateTime.utc_now()

      assert_raise FunctionClauseError, fn ->
        Time.hours_ago(0.5, time)
      end
    end
  end

  describe "#seconds_after" do
    test "Return time in future in seconds is time is more than zero" do
      time = NaiveDateTime.utc_now()
      assert NaiveDateTime.add(time, 1, :seconds) == Time.seconds_after(1, time)
      assert NaiveDateTime.add(time, 20, :seconds) == Time.seconds_after(20, time)
      assert NaiveDateTime.add(time, 300, :seconds) == Time.seconds_after(300, time)
      assert NaiveDateTime.add(time, 1000, :seconds) == Time.seconds_after(1000, time)
    end

    test "Return time in past in seconds is time is less than zero" do
      time = NaiveDateTime.utc_now()
      assert NaiveDateTime.add(time, -1, :seconds) == Time.seconds_after(-1, time)
      assert NaiveDateTime.add(time, -20, :seconds) == Time.seconds_after(-20, time)
      assert NaiveDateTime.add(time, -300, :seconds) == Time.seconds_after(-300, time)
      assert NaiveDateTime.add(time, -1000, :seconds) == Time.seconds_after(-1000, time)
    end

    test "Use NaiveDateTime.utc_now() if no second parameter" do
      time = NaiveDateTime.add(NaiveDateTime.utc_now(), 1200, :seconds)
      standard = NaiveDateTime.add(time, 1201, :seconds)

      with_mocks([{NaiveDateTime, [], [utc_now: fn -> time end, add: fn _, _, _ -> standard end]}]) do
        assert standard == Time.seconds_after(1)
      end
    end

    test "Raise error if seconds is not integer" do
      time = NaiveDateTime.utc_now()

      assert_raise FunctionClauseError, fn ->
        Time.seconds_after(0.5, time)
      end
    end
  end

  describe "#scheduling_time_label" do
    test "Return right label" do
      time = NaiveDateTime.utc_now()
      {{year, month, day}, {hours, minutes, seconds}} = NaiveDateTime.to_erl(time)
      standard = "#{day}.#{month}.#{year} #{hours}:#{minutes}:#{seconds}"

      assert standard == Time.scheduling_time_label(time)
    end

    test "Raise error if time is not NaiveDateTime" do
      time = DateTime.utc_now()

      assert_raise FunctionClauseError, fn ->
        Time.scheduling_time_label(time)
      end
    end
  end

  describe "#soap_datetime" do
    test "Return right string #1" do
      {:ok, time} = NaiveDateTime.from_erl({{2019, 4, 22}, {11, 11, 11}})
      assert "2019-04-22T11:11:11+00:00" = Time.soap_datetime(time)
    end

    test "Return right string #2" do
      {:ok, time} = NaiveDateTime.from_erl({{2018, 12, 2}, {1, 1, 11}})
      assert "2018-12-02T01:01:11+00:00" = Time.soap_datetime(time)
    end

    test "Return right string #3" do
      {:ok, time} = NaiveDateTime.from_erl({{2017, 4, 3}, {4, 50, 0}})
      assert "2017-04-03T04:50:00+00:00" = Time.soap_datetime(time)
    end

    test "Raise error if time is not NaiveDateTime" do
      time = DateTime.utc_now()

      assert_raise FunctionClauseError, fn ->
        Time.soap_datetime(time)
      end
    end
  end
end
