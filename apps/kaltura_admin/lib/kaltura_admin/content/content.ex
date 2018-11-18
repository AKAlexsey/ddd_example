defmodule KalturaAdmin.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias KalturaAdmin.Repo

  alias KalturaAdmin.Content.TvStream

  @doc """
  Returns the list of tv_streams.

  ## Examples

      iex> list_tv_streams()
      [%TvStream{}, ...]

  """
  def list_tv_streams(preload \\ []) do
    Repo.all(TvStream)
    |> Repo.preload(preload)
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
  def get_tv_stream!(id), do: Repo.get!(TvStream, id)

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
    |> Repo.insert()
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
    |> Repo.update()
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
    Repo.delete(tv_stream)
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

  alias KalturaAdmin.Content.Program

  @doc """
  Returns the list of programs.

  ## Examples

      iex> list_programs()
      [%Program{}, ...]

  """
  def list_programs do
    Repo.all(Program)
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
  def get_program!(id), do: Repo.get!(Program, id)

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
    |> Repo.insert()
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
    |> Repo.update()
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
    Repo.delete(program)
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

  alias KalturaAdmin.Content.ProgramRecord

  @doc """
  Returns the list of program_records.

  ## Examples

      iex> list_program_records()
      [%ProgramRecord{}, ...]

  """
  def list_program_records do
    Repo.all(ProgramRecord)
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
  def get_program_record!(id), do: Repo.get!(ProgramRecord, id)

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
    |> Repo.insert()
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
    |> Repo.update()
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
    Repo.delete(program_record)
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
end
