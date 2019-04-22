defmodule CtiKaltura.ProgramScheduling.EpgFileParserTest do
  use ExUnit.Case, async: false

  alias CtiKaltura.ProgramScheduling.EpgFileParser

  setup do
    files_dir = Application.get_env(:cti_kaltura, :epg_file_parser)[:files_directory]

    processed_files_dir =
      Application.get_env(:cti_kaltura, :epg_file_parser)[:processed_files_directory]

    {:ok, files_dir: files_dir, processed_files_dir: processed_files_dir}
  end

  describe "#one_file_data" do
    test "Return right file data. Move file to processed", %{
      files_dir: files_dir,
      processed_files_dir: processed_files_dir
    } do
      moving_file_name_standard = "KalturaEPG_000000014_190406.xml"

      assert :no_file == EpgFileParser.get_first_file(processed_files_dir)
      assert moving_file_name_standard == Path.basename(EpgFileParser.get_first_file(files_dir))

      standard =
        {:ok,
         %{
           linear_channel: %{epg_id: "000000014"},
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
         }}

      assert standard == EpgFileParser.one_file_data(files_dir, processed_files_dir)

      assert moving_file_name_standard ==
               Path.basename(EpgFileParser.get_first_file(processed_files_dir))

      assert moving_file_name_standard != Path.basename(EpgFileParser.get_first_file(files_dir))

      return_file = EpgFileParser.get_first_file(processed_files_dir)

      EpgFileParser.move_file_to_processed(return_file, files_dir)

      assert :no_file == EpgFileParser.get_first_file(processed_files_dir)
      assert moving_file_name_standard == Path.basename(EpgFileParser.get_first_file(files_dir))
    end

    test "Return error if there is no files in directory", %{
      files_dir: files_dir,
      processed_files_dir: processed_files_dir
    } do
      assert {:ok, :no_file} == EpgFileParser.one_file_data(processed_files_dir, files_dir)
    end
  end

  describe "#get_first_file" do
    test "Returns first file in directory", %{files_dir: files_dir} do
      moving_file_name_standard = "KalturaEPG_000000014_190406.xml"

      assert moving_file_name_standard == Path.basename(EpgFileParser.get_first_file(files_dir))
    end
  end

  describe "#get_linear_channel" do
    test "Return linear channel map", %{files_dir: files_dir} do
      {:ok, file} = File.read(EpgFileParser.get_first_file(files_dir))
      assert %{epg_id: "000000014"} == EpgFileParser.get_linear_channel(file)
    end
  end

  describe "#get_programs_data" do
    test "Return programs_data as list of maps", %{files_dir: files_dir} do
      {:ok, file} = File.read(EpgFileParser.get_first_file(files_dir))

      standard = [
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

      assert EpgFileParser.get_programs_data(file) == standard
    end
  end

  describe "#move_file_to_processed" do
    test "Move file to processed directory", %{
      files_dir: files_dir,
      processed_files_dir: processed_files_dir
    } do
      moving_file_name_standard = "KalturaEPG_000000014_190406.xml"

      moving_file = EpgFileParser.get_first_file(files_dir)

      assert :no_file == EpgFileParser.get_first_file(processed_files_dir)
      assert moving_file_name_standard == Path.basename(EpgFileParser.get_first_file(files_dir))

      EpgFileParser.move_file_to_processed(moving_file, processed_files_dir)

      assert moving_file_name_standard ==
               Path.basename(EpgFileParser.get_first_file(processed_files_dir))

      assert moving_file_name_standard != Path.basename(EpgFileParser.get_first_file(files_dir))

      return_file = EpgFileParser.get_first_file(processed_files_dir)

      EpgFileParser.move_file_to_processed(return_file, files_dir)

      assert :no_file == EpgFileParser.get_first_file(processed_files_dir)
      assert moving_file_name_standard == Path.basename(EpgFileParser.get_first_file(files_dir))
    end
  end
end
