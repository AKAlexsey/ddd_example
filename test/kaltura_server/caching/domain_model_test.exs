defmodule CtiKaltura.DomainModelTest do
  use CtiKaltura.MnesiaTestCase

  describe "#cidr_fields_for_search" do
    test "Add three fields" do
      cidr = "123.23.23.14/28"
      parsed_cidr = CIDR.parse(cidr)

      assert %{
               parsed_cidr: parsed_cidr,
               first_number_ip: 2_065_110_784,
               last_number_ip: 2_065_110_799
             } == DomainModel.cidr_fields_for_search(cidr)
    end
  end

  describe "#make_table_record" do
    setup do
      region_id = 777
      table_name = DomainModel.Region
      {:ok, id: region_id, table_name: table_name}
    end

    test "Create new table record with given params", %{id: region_id, table_name: table_name} do
      name = Faker.Lorem.word()
      status = "ACTIVE"
      subnet_ids = []
      server_group_ids = []

      Amnesia.transaction(fn -> table_name.delete(region_id) end)
      assert is_nil(Amnesia.transaction(fn -> table_name.read(region_id) end))

      param_tuple = {table_name, region_id, name, status, subnet_ids, server_group_ids}

      assert %{
               __struct__: ^table_name,
               id: ^region_id,
               name: ^name,
               status: ^status,
               subnet_ids: ^subnet_ids,
               server_group_ids: ^server_group_ids
             } = DomainModel.make_table_record(param_tuple)
    end
  end
end
