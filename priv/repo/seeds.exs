# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CtiKaltura.Repo.insert!(%CtiKaltura.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will halt execution if something goes wrong.

alias CtiKaltura.{Repo, User, Factory}

Faker.start()

%User{}
|> User.changeset(%{
  email: "admin@cti.ru",
  first_name: "Admin",
  last_name: "Admin",
  password: "qwe"
})
|> Repo.insert!()

# Creating data for testing

get_ids = fn collection -> Enum.map(collection, fn {:ok, el} -> el.id end) end

symbolize_keys = fn data ->
  for {key, val} <- data, into: %{}, do: {String.to_atom(key), val}
end

{:ok, region_names} =
  YamlElixir.read_from_file("#{File.cwd!()}/priv/repo/seed_data/region_names.yml")

region_ids =
  region_names
  |> Map.get("region_names")
  |> Enum.map(fn name -> Factory.insert(:region, %{name: name}) end)
  |> get_ids.()

{:ok, subnet_cidrs} =
  YamlElixir.read_from_file("#{File.cwd!()}/priv/repo/seed_data/subnet_cidrs.yml")

subnet_cidrs
|> Map.get("subnet_cidrs")
|> Enum.with_index()
|> Enum.map(fn {cidr, index} ->
  region_id = Enum.at(region_ids, div(index, 20))
  Factory.insert(:subnet, %{cidr: cidr, region_id: region_id, name: "name#{index}"})
end)
|> get_ids.()

max_port = 1024

{:ok, server_domains} =
  YamlElixir.read_from_file("#{File.cwd!()}/priv/repo/seed_data/server_domains.yml")

dvr_servers_count = 4

server_domain_names = Map.get(server_domains, "server_domains")

dvr_server_ids =
  server_domain_names
  |> Enum.slice(0, dvr_servers_count)
  |> Enum.map(fn domain_name ->
    Factory.insert(:server, %{
      domain_name: domain_name,
      port: 80,
      weight: 20 + :rand.uniform(31),
      type: "DVR"
    })
  end)
  |> get_ids.()

edge_server_ids =
  server_domain_names
  |> Enum.slice(dvr_servers_count, length(server_domain_names))
  |> Enum.map(fn domain_name ->
    Factory.insert(:server, %{
      domain_name: domain_name,
      port: 80,
      weight: 20 + :rand.uniform(31),
      type: "EDGE"
    })
  end)
  |> get_ids.()

random_stream_function = fn collection, batch_size ->
  cycle =
    collection
    |> Enum.shuffle()
    |> Stream.cycle()

  max_offset = length(collection)

  fn ->
    cycle
    |> Enum.slice(:rand.uniform(max_offset), batch_size)
  end
end

random_region_ids = random_stream_function.(region_ids, 24)
random_dvr_server_ids = random_stream_function.(dvr_server_ids, 2)
random_edge_server_ids = random_stream_function.(edge_server_ids, 5)

server_group_ids =
  Enum.map(0..24, fn order_number ->
    Factory.insert(:server_group, %{
      region_ids: random_region_ids.(),
      server_ids: Enum.uniq(random_edge_server_ids.() ++ random_dvr_server_ids.()),
      name: "name#{order_number}"
    })
  end)
  |> get_ids.()

random_server_group_id = fn -> random_stream_function.(server_group_ids, 1).() |> hd() end

{:ok, tv_stream_data} =
  YamlElixir.read_from_file("#{File.cwd!()}/priv/repo/seed_data/tv_stream_data.yml")

linear_channel_ids =
  tv_stream_data
  |> Map.get("tv_stream_data")
  |> Enum.map(fn tv_stream_data ->
    data =
      symbolize_keys.(tv_stream_data)
      |> Map.update!(:tv_streams, fn tv_streams ->
        Enum.map(tv_streams, fn tv_stream ->
          tv_stream_prams = symbolize_keys.(tv_stream)
          Factory.build(:tv_stream, tv_stream_prams).changes
        end)
      end)
      |> (fn %{epg_id: epg_id} = data ->
            %{}

            Map.merge(data, %{
              name: "#{epg_id}_name",
              code_name: "#{epg_id}_code_name",
              dvr_enabled: true,
              server_group_id: random_server_group_id.()
            })
          end).()

    Factory.insert(:linear_channel, data)
  end)
  |> get_ids.()

{:ok, program_names} =
  YamlElixir.read_from_file("#{File.cwd!()}/priv/repo/seed_data/program_names.yml")

program_ids =
  program_names
  |> Map.get("program_names")
  |> Enum.with_index()
  |> Enum.map(fn {program_name, index} ->
    Factory.insert(:program, %{
      name: program_name,
      epg_id: "p_epg_#{index}",
      linear_channel_id: Enum.at(linear_channel_ids, index)
    })
  end)
  |> get_ids.()

program_ids
|> Enum.each(fn program_id ->
  dvr_server_ids
  |> Enum.each(fn server_id ->
    CtiKaltura.Enums.stream_protocols()
    |> Enum.each(fn protocol ->
      CtiKaltura.Enums.encryptions()
      |> Enum.each(fn encryption ->
        Factory.insert(:program_record, %{
          server_id: server_id,
          program_id: program_id,
          status: "COMPLETED",
          protocol: protocol,
          encryption: encryption
        })
      end)
    end)
  end)
end)
