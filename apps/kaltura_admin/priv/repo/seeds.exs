# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     KalturaAdmin.Repo.insert!(%KalturaAdmin.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will halt execution if something goes wrong.

alias KalturaAdmin.{Repo, User, Factory}

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
  YamlElixir.read_from_file(
    "#{File.cwd!()}/apps/kaltura_admin/priv/repo/seed_data/region_names.yml"
  )

region_ids =
  region_names
  |> Map.get("region_names")
  |> Enum.map(fn name -> Factory.insert(:region, %{name: name}) end)
  |> get_ids.()

{:ok, subnet_cidrs} =
  YamlElixir.read_from_file(
    "#{File.cwd!()}/apps/kaltura_admin/priv/repo/seed_data/subnet_cidrs.yml"
  )

subnet_cidrs
|> Map.get("subnet_cidrs")
|> Enum.with_index()
|> Enum.map(fn {cidr, index} ->
  region_id = Enum.at(region_ids, div(index, 20))
  Factory.insert(:subnet, %{cidr: cidr, region_id: region_id})
end)
|> get_ids.()

max_port = 1024

{:ok, server_domains} =
  YamlElixir.read_from_file(
    "#{File.cwd!()}/apps/kaltura_admin/priv/repo/seed_data/server_domains.yml"
  )

dvr_servers_count = 10

server_domain_names = Map.get(server_domains, "server_domains")

dvr_server_ids =
  server_domain_names
  |> Enum.slice(0, dvr_servers_count)
  |> Enum.map(fn domain_name ->
    Factory.insert(:server, %{
      domain_name: domain_name,
      port: :rand.uniform(max_port),
      weight: 20 + :rand.uniform(31),
      type: :dvr
    })
  end)
  |> get_ids.()

edge_server_ids =
  server_domain_names
  |> Enum.slice(dvr_servers_count, length(server_domain_names))
  |> Enum.map(fn domain_name ->
    Factory.insert(:server, %{
      domain_name: domain_name,
      port: :rand.uniform(max_port),
      weight: 20 + :rand.uniform(31),
      type: :edge
    })
  end)
  |> get_ids.()

{:ok, tv_stream_data} =
  YamlElixir.read_from_file(
    "#{File.cwd!()}/apps/kaltura_admin/priv/repo/seed_data/tv_stream_data.yml"
  )

tv_stream_ids =
  tv_stream_data
  |> Map.get("tv_stream_data")
  |> Enum.map(fn tv_stream_data ->
    data =
      symbolize_keys.(tv_stream_data)
      |> Map.update(:protocol, :"", &String.to_atom/1)

    Factory.insert(:tv_stream, data)
  end)
  |> get_ids.()

{:ok, program_names} =
  YamlElixir.read_from_file(
    "#{File.cwd!()}/apps/kaltura_admin/priv/repo/seed_data/program_names.yml"
  )

program_ids =
  program_names
  |> Map.get("program_names")
  |> Enum.with_index()
  |> Enum.map(fn {program_name, index} ->
    Factory.insert(:program, %{name: program_name, epg_id: "p_epg_#{index}"})
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
random_edge_server_ids = random_stream_function.(edge_server_ids, 20)

random_tv_stream_ids = fn order_number ->
  shuffled_ids = Enum.shuffle(tv_stream_ids)

  cond do
    order_number in 0..9 ->
      shuffled_ids

    order_number in 10..19 ->
      Enum.slice(shuffled_ids, :rand.uniform(501) - 1, 500)

    true ->
      Enum.slice(shuffled_ids, :rand.uniform(751) - 1, 250)
  end
end

0..24
|> Enum.into([])
|> Enum.each(fn order_number ->
  Factory.insert(:server_group, %{
    region_ids: random_region_ids.(),
    tv_stream_ids: random_tv_stream_ids.(order_number),
    server_ids: random_edge_server_ids.() ++ random_dvr_server_ids.()
  })
end)

protocols = KalturaAdmin.StreamProtocol.__enum_map__()
            |> Keyword.keys()

program_ids
|> Enum.each(fn program_id ->
  dvr_server_ids
  |> Enum.each(fn server_id ->
    protocols
    |> Enum.each(fn protocol ->
      Factory.insert(:program_record, %{
        server_id: server_id,
        program_id: program_id,
        status: :completed,
        protocol: protocol
      })
    end)
  end)
end)
