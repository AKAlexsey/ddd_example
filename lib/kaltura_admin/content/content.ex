defmodule CtiKaltura.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias CtiKaltura.Repo

  alias CtiKaltura.Content.LinearChannel

  @doc """
  Returns the list of linear_channels.

  ## Examples

      iex> list_linear_channels()
      [%LinearChannel{}, ...]

  """
  def list_linear_channels(preload \\ []) do
    LinearChannel
    |> Repo.all()
    |> Repo.preload(preload)
  end

  @doc """
  Gets a single linear_channel.

  Raises `Ecto.NoResultsError` if the Linear channel does not exist.

  ## Examples

      iex> get_linear_channel!(123)
      %LinearChannel{}

      iex> get_linear_channel!(456)
      ** (Ecto.NoResultsError)

  """
  def get_linear_channel!(id, preload \\ []) do
    LinearChannel
    |> Repo.get!(id)
    |> Repo.preload(preload)
  end

  @doc """
  Возвращает LinearChannel по epg_id
  """
  @spec get_linear_channel_by_epg(binary | integer) :: LinearChannel.t() | nil
  def get_linear_channel_by_epg(epg_id) do
    from(lc in LinearChannel, where: lc.epg_id == ^epg_id)
    |> Repo.one()
  end

  @doc """
  Creates a linear_channel.

  ## Examples

      iex> create_linear_channel(%{field: value})
      {:ok, %LinearChannel{}}

      iex> create_linear_channel(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_linear_channel(attrs \\ %{}) do
    %LinearChannel{}
    |> LinearChannel.changeset(attrs)
    |> Repo.insert_and_notify()
  end

  @doc """
  Updates a linear_channel.

  ## Examples

      iex> update_linear_channel(linear_channel, %{field: new_value})
      {:ok, %LinearChannel{}}

      iex> update_linear_channel(linear_channel, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_linear_channel(%LinearChannel{} = linear_channel, attrs) do
    linear_channel
    |> LinearChannel.changeset(attrs)
    |> Repo.update_and_notify()
  end

  @doc """
  Deletes a LinearChannel.

  ## Examples

      iex> delete_linear_channel(linear_channel)
      {:ok, %LinearChannel{}}

      iex> delete_linear_channel(linear_channel)
      {:error, %Ecto.Changeset{}}

  """
  def delete_linear_channel(%LinearChannel{} = linear_channel) do
    linear_channel
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.foreign_key_constraint(
      :programs,
      name: :programs_linear_channel_id_fkey,
      message: "There are programs for current channel. Remove related programs and try again"
    )
    |> Repo.delete_and_notify()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking linear_channel changes.

  ## Examples

      iex> change_linear_channel(linear_channel)
      %Ecto.Changeset{source: %LinearChannel{}}

  """
  def change_linear_channel(%LinearChannel{} = linear_channel) do
    LinearChannel.changeset(linear_channel, %{})
  end

  alias CtiKaltura.Content.Program

  @doc """
  Returns the list of programs.

  ## Examples

      iex> list_programs()
      [%Program{}, ...]

  """
  def list_programs(preload \\ []) do
    Program
    |> Repo.all()
    |> Repo.preload(preload)
  end

  @doc """
  Gets a single program.

  Raises `Ecto.NoResultsError` if the Program does not exist.

  ## Examples

      iex> get_program!(123)
      %Program{}

      iex> get_program!(456)
      ** (Ecto.NoResultsError)

  """
  def get_program!(id, preload \\ []) do
    Program
    |> Repo.get!(id)
    |> Repo.preload(preload)
  end

  @doc """
  Creates a program.

  ## Examples

      iex> create_program(%{field: value})
      {:ok, %Program{}}

      iex> create_program(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_program(attrs \\ %{}) do
    %Program{}
    |> Program.changeset(attrs)
    |> Repo.insert_and_notify()
  end

  @doc """
  Updates a program.

  ## Examples

      iex> update_program(program, %{field: new_value})
      {:ok, %Program{}}

      iex> update_program(program, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_program(%Program{} = program, attrs) do
    program
    |> Program.changeset(attrs)
    |> Repo.update_and_notify()
  end

  @doc """
  Deletes a Program.

  ## Examples

      iex> delete_program(program)
      {:ok, %Program{}}

      iex> delete_program(program)
      {:error, %Ecto.Changeset{}}

  """
  def delete_program(%Program{} = program) do
    program
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.foreign_key_constraint(
      :program_records,
      name: :program_records_program_id_fkey,
      message:
        "There are program records for current program. Remove related program records and try again"
    )
    |> Repo.delete_and_notify()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking program changes.

  ## Examples

      iex> change_program(program)
      %Ecto.Changeset{source: %Program{}}

  """
  def change_program(%Program{} = program) do
    Program.changeset(program, %{})
  end

  @doc """
  Возвращает программы, которые должны начаться в заданный интервал времени
  """
  @spec delete_programs_from_interval(NaiveDateTime.t(), NaiveDateTime.t(), integer) ::
          {:ok, integer}
  def delete_programs_from_interval(start_datetime, end_datetime, linear_channel_id) do
    from(
      p in Program,
      where:
        p.start_datetime >= ^start_datetime and p.start_datetime <= ^end_datetime and
          p.linear_channel_id == ^linear_channel_id
    )
    |> Repo.delete_all()
  end

  alias CtiKaltura.Content.ProgramRecord

  @doc """
  Returns the list of program_records.

  ## Examples

      iex> list_program_records()
      [%ProgramRecord{}, ...]

  """
  def list_program_records do
    Repo.all(ProgramRecord)
  end

  def list_program_records(program_id) do
    Repo.all(from(pr in ProgramRecord, where: pr.program_id == ^program_id))
  end

  @doc """
  Gets a single program_record.

  Raises `Ecto.NoResultsError` if the Program record does not exist.

  ## Examples

      iex> get_program_record!(123)
      %ProgramRecord{}

      iex> get_program_record!(456)
      ** (Ecto.NoResultsError)

  """
  def get_program_record!(id, preload \\ []) do
    ProgramRecord
    |> Repo.get!(id)
    |> Repo.preload(preload)
  end

  @doc """
  Creates a program_record.

  ## Examples

      iex> create_program_record(%{field: value})
      {:ok, %ProgramRecord{}}

      iex> create_program_record(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_program_record(attrs \\ %{}) do
    %ProgramRecord{}
    |> ProgramRecord.changeset(attrs)
    |> Repo.insert_and_notify()
  end

  @doc """
  Updates a program_record.

  ## Examples

      iex> update_program_record(program_record, %{field: new_value})
      {:ok, %ProgramRecord{}}

      iex> update_program_record(program_record, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_program_record(%ProgramRecord{} = program_record, attrs) do
    program_record
    |> ProgramRecord.changeset(attrs)
    |> Repo.update_and_notify()
  end

  @doc """
  Deletes a ProgramRecord.

  ## Examples

      iex> delete_program_record(program_record)
      {:ok, %ProgramRecord{}}

      iex> delete_program_record(program_record)
      {:error, %Ecto.Changeset{}}

  """
  def delete_program_record(%ProgramRecord{} = program_record) do
    Repo.delete_and_notify(program_record)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking program_record changes.

  ## Examples

      iex> change_program_record(program_record)
      %Ecto.Changeset{source: %ProgramRecord{}}

  """
  def change_program_record(%ProgramRecord{} = program_record) do
    ProgramRecord.changeset(program_record, %{})
  end

  alias CtiKaltura.Content.TvStream

  @doc """
  Returns the list of tv_streams.

  ## Examples

      iex> list_tv_streams()
      [%TvStream{}, ...]

  """
  def list_tv_streams do
    Repo.all(TvStream)
  end

  @doc """
  Gets a single tv_stream.

  Raises `Ecto.NoResultsError` if the Tv stream does not exist.

  ## Examples

      iex> get_tv_stream!(123)
      %TvStream{}

      iex> get_tv_stream!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tv_stream!(id, preload \\ []) do
    TvStream
    |> Repo.get!(id)
    |> Repo.preload(preload)
  end

  @doc """
  Creates a tv_stream.

  ## Examples

      iex> create_tv_stream(%{field: value})
      {:ok, %TvStream{}}

      iex> create_tv_stream(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tv_stream(attrs \\ %{}) do
    %TvStream{}
    |> TvStream.changeset(attrs)
    |> Repo.insert_and_notify()
  end

  @doc """
  Updates a tv_stream.

  ## Examples

      iex> update_tv_stream(tv_stream, %{field: new_value})
      {:ok, %TvStream{}}

      iex> update_tv_stream(tv_stream, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tv_stream(%TvStream{} = tv_stream, attrs) do
    tv_stream
    |> TvStream.changeset(attrs)
    |> Repo.update_and_notify()
  end

  @doc """
  Deletes a TvStream.

  ## Examples

      iex> delete_tv_stream(tv_stream)
      {:ok, %TvStream{}}

      iex> delete_tv_stream(tv_stream)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tv_stream(%TvStream{} = tv_stream) do
    Repo.delete_and_notify(tv_stream)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tv_stream changes.

  ## Examples

      iex> change_tv_stream(tv_stream)
      %Ecto.Changeset{source: %TvStream{}}

  """
  def change_tv_stream(%TvStream{} = tv_stream) do
    TvStream.changeset(tv_stream, %{})
  end
end
