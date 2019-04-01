defmodule CtiKaltura.ServerTest do
  use CtiKaltura.DataCase

  alias CtiKaltura.Servers.Server

  describe "#changeset" do
    setup do
      {:ok, server} = Factory.insert(:server)

      {:ok, server: server}
    end

    test "Validate :type presence", %{server: server} do
      refute is_nil(server.type)
      changeset = Server.changeset(server, %{type: nil})

      assert %{valid?: false, errors: [type: _]} = changeset
    end

    test "Validate :domain_name presence", %{server: server} do
      refute is_nil(server.domain_name)
      changeset = Server.changeset(server, %{domain_name: nil})

      assert %{valid?: false, errors: [domain_name: _]} = changeset
    end

    test "Validate :domain_name format", %{server: server} do
      changeset = Server.changeset(server, %{domain_name: "domainname"})
      assert %{valid?: false, errors: [domain_name: _]} = changeset

      changeset = Server.changeset(server, %{domain_name: "domain_name.name"})
      assert %{valid?: false, errors: [domain_name: _]} = changeset

      changeset = Server.changeset(server, %{domain_name: "domain_namename"})
      assert %{valid?: false, errors: [domain_name: _]} = changeset

      changeset = Server.changeset(server, %{domain_name: "domain.name"})
      assert %{valid?: true} = changeset

      changeset = Server.changeset(server, %{domain_name: "domain-name.high-order-domain"})
      assert %{valid?: true} = changeset
    end

    test "Validate :ip presence", %{server: server} do
      refute is_nil(server.ip)
      changeset = Server.changeset(server, %{ip: nil})

      assert %{valid?: false, errors: [ip: _]} = changeset
    end

    test "Validate :port presence", %{server: server} do
      refute is_nil(server.port)
      changeset = Server.changeset(server, %{port: nil})

      assert %{valid?: false, errors: [port: _]} = changeset
    end

    test "Validate :status presence", %{server: server} do
      refute is_nil(server.status)
      changeset = Server.changeset(server, %{status: nil})

      assert %{valid?: false, errors: [status: _]} = changeset
    end

    test "Validate :prefix presence", %{server: server} do
      refute is_nil(server.prefix)
      changeset = Server.changeset(server, %{prefix: nil})

      assert %{valid?: false, errors: [prefix: _]} = changeset
    end

    test "Validate : [domain_name:type] is unique", %{server: server} do
      {:ok, other_server} = Factory.insert(:server)

      changeset =
        Server.changeset(server, %{domain_name: other_server.domain_name, type: other_server.type})

      assert {:error, %{valid?: false, errors: [domain_name: _]}} = Repo.update(changeset)
    end

    test "Validate :port value", %{server: server} do
      changeset = Server.changeset(server, %{port: 81})
      assert %{valid?: false, errors: [port: _]} = changeset

      changeset = Server.changeset(server, %{port: 79})
      assert %{valid?: false, errors: [port: _]} = changeset

      changeset = Server.changeset(server, %{port: 80})
      assert %{valid?: true} = changeset

      changeset = Server.changeset(server, %{port: 444})
      assert %{valid?: false, errors: [port: _]} = changeset

      changeset = Server.changeset(server, %{port: 442})
      assert %{valid?: false, errors: [port: _]} = changeset

      changeset = Server.changeset(server, %{port: 443})
      assert %{valid?: true} = changeset
    end

    test "Validate :weight presence", %{server: server} do
      refute is_nil(server.weight)
      changeset = Server.changeset(server, %{weight: nil})

      assert %{valid?: false, errors: [weight: _]} = changeset
    end

    test "Validate :weight between 1 and 100", %{server: server} do
      changeset = Server.changeset(server, %{weight: 0})
      assert %{valid?: false, errors: [weight: _]} = changeset

      changeset = Server.changeset(server, %{weight: 101})
      assert %{valid?: false, errors: [weight: _]} = changeset

      changeset = Server.changeset(server, %{weight: 1})
      assert %{valid?: true} = changeset

      changeset = Server.changeset(server, %{weight: 100})
      assert %{valid?: true} = changeset

      changeset = Server.changeset(server, %{weight: 50})
      assert %{valid?: true} = changeset
    end

    test "Validate :manage_port between 0 and 65535", %{server: server} do
      changeset = Server.changeset(server, %{manage_port: -1})
      assert %{valid?: false, errors: [manage_port: _]} = changeset

      changeset = Server.changeset(server, %{manage_port: 65_536})
      assert %{valid?: false, errors: [manage_port: _]} = changeset

      changeset = Server.changeset(server, %{manage_port: 0})
      assert %{valid?: true} = changeset

      changeset = Server.changeset(server, %{manage_port: 65_535})
      assert %{valid?: true} = changeset

      changeset = Server.changeset(server, %{manage_port: 300})
      assert %{valid?: true} = changeset
    end

    test "Validate :prefix is uniq", %{server: server} do
      {:ok, other_server} = Factory.insert(:server)

      refute server.prefix == other_server.prefix
      changeset = Server.changeset(server, %{prefix: other_server.prefix})
      assert {:error, %{valid?: false, errors: [prefix: _]}} = Repo.update(changeset)
    end

    test "Validate :prefix format", %{server: server} do
      changeset = Server.changeset(server, %{prefix: "$!@$prefix"})
      assert %{valid?: false, errors: [prefix: _]} = changeset

      changeset = Server.changeset(server, %{prefix: ".prefix."})
      assert %{valid?: false, errors: [prefix: _]} = changeset

      changeset = Server.changeset(server, %{prefix: "prefix-1"})
      assert %{valid?: true} = changeset

      changeset = Server.changeset(server, %{prefix: "prefix1"})
      assert %{valid?: true} = changeset

      changeset = Server.changeset(server, %{prefix: "prefix"})
      assert %{valid?: true} = changeset

      changeset = Server.changeset(server, %{prefix: "1234"})
      assert %{valid?: true} = changeset
    end

    test "Validate :healthcheck_path format", %{server: server} do
      changeset = Server.changeset(server, %{healthcheck_path: "$!@$path"})
      assert %{valid?: false, errors: [healthcheck_path: _]} = changeset

      changeset = Server.changeset(server, %{healthcheck_path: "path"})
      assert %{valid?: false, errors: [healthcheck_path: _]} = changeset

      changeset = Server.changeset(server, %{healthcheck_path: "/path-1"})
      assert %{valid?: true} = changeset

      changeset = Server.changeset(server, %{healthcheck_path: "/path1"})
      assert %{valid?: true} = changeset

      changeset = Server.changeset(server, %{healthcheck_path: "/path"})
      assert %{valid?: true} = changeset

      changeset = Server.changeset(server, %{healthcheck_path: "/1234"})
      assert %{valid?: true} = changeset
    end

    test "Validate :ip format", %{server: server} do
      changeset = Server.changeset(server, %{ip: "123.123.123.i23"})
      assert %{valid?: false, errors: [ip: _]} = changeset

      changeset = Server.changeset(server, %{ip: "123.123.123123"})
      assert %{valid?: false, errors: [ip: _]} = changeset

      changeset = Server.changeset(server, %{ip: "123.123.123."})
      assert %{valid?: false, errors: [ip: _]} = changeset

      changeset = Server.changeset(server, %{ip: "123.123.123"})
      assert %{valid?: false, errors: [ip: _]} = changeset

      changeset = Server.changeset(server, %{ip: "123.123.123.1123"})
      assert %{valid?: false, errors: [ip: _]} = changeset

      changeset = Server.changeset(server, %{ip: "123.123.123.256"})
      assert %{valid?: false} = changeset

      changeset = Server.changeset(server, %{ip: "123.123.123.123"})
      assert %{valid?: true} = changeset

      changeset = Server.changeset(server, %{ip: "183.134.153.134"})
      assert %{valid?: true} = changeset
    end

    test "Validate :manage_ip format", %{server: server} do
      changeset = Server.changeset(server, %{manage_ip: "123.123.123.i23"})
      assert %{valid?: false, errors: [manage_ip: _]} = changeset

      changeset = Server.changeset(server, %{manage_ip: "123.123.123123"})
      assert %{valid?: false, errors: [manage_ip: _]} = changeset

      changeset = Server.changeset(server, %{manage_ip: "123.123.123."})
      assert %{valid?: false, errors: [manage_ip: _]} = changeset

      changeset = Server.changeset(server, %{manage_ip: "123.123.123"})
      assert %{valid?: false, errors: [manage_ip: _]} = changeset

      changeset = Server.changeset(server, %{manage_ip: "123.123.123.1123"})
      assert %{valid?: false, errors: [manage_ip: _]} = changeset

      changeset = Server.changeset(server, %{manage_ip: "123.123.123.256"})
      assert %{valid?: false} = changeset

      changeset = Server.changeset(server, %{manage_ip: "123.123.123.255"})
      assert %{valid?: true} = changeset

      changeset = Server.changeset(server, %{manage_ip: "127.0.0.1"})
      assert %{valid?: true} = changeset

      changeset = Server.changeset(server, %{manage_ip: "183.134.153.134"})
      assert %{valid?: true} = changeset
    end
  end
end
