defmodule CtiKaltura.DomainModelHandlers.AbstractHandlerTest do
  use ExUnit.Case

  import Mock

  alias CtiKaltura.DomainModelHandlers.{
    ProgramHandler,
    ProgramRecordHandler,
    RegionHandler,
    ServerGroupHandler,
    ServerHandler,
    SubnetHandler,
    LinearChannelHandler
  }

  alias CtiKaltura.Handlers.DomainModelHandler

  describe "#handle" do
    setup do
      {:ok, test_attrs: %{argument1: "value1", argument2: 2}}
    end

    test "If model name is Program", %{test_attrs: test_attrs} do
      with_mock(ProgramHandler, handle: fn :action, %{} -> :ok end) do
        DomainModelHandler.handle(:action, %{model_name: "Program", attrs: test_attrs})
        assert_called(ProgramHandler.handle(:action, test_attrs))
      end
    end

    test "If model name is ProgramRecord", %{test_attrs: test_attrs} do
      with_mock(ProgramRecordHandler, handle: fn :action, %{} -> :ok end) do
        DomainModelHandler.handle(:action, %{model_name: "ProgramRecord", attrs: test_attrs})
        assert_called(ProgramRecordHandler.handle(:action, test_attrs))
      end
    end

    test "If model name is Region", %{test_attrs: test_attrs} do
      with_mock(RegionHandler, handle: fn :action, %{} -> :ok end) do
        DomainModelHandler.handle(:action, %{model_name: "Region", attrs: test_attrs})
        assert_called(RegionHandler.handle(:action, test_attrs))
      end
    end

    test "If model name is ServerGroup", %{test_attrs: test_attrs} do
      with_mock(ServerGroupHandler, handle: fn :action, %{} -> :ok end) do
        DomainModelHandler.handle(:action, %{model_name: "ServerGroup", attrs: test_attrs})
        assert_called(ServerGroupHandler.handle(:action, test_attrs))
      end
    end

    test "If model name is Server", %{test_attrs: test_attrs} do
      with_mock(ServerHandler, handle: fn :action, %{} -> :ok end) do
        DomainModelHandler.handle(:action, %{model_name: "Server", attrs: test_attrs})
        assert_called(ServerHandler.handle(:action, test_attrs))
      end
    end

    test "If model name is Subnet", %{test_attrs: test_attrs} do
      with_mock(SubnetHandler, handle: fn :action, %{} -> :ok end) do
        DomainModelHandler.handle(:action, %{model_name: "Subnet", attrs: test_attrs})
        assert_called(SubnetHandler.handle(:action, test_attrs))
      end
    end

    test "If model name is LinearChannel", %{test_attrs: test_attrs} do
      with_mock(LinearChannelHandler, handle: fn :action, %{} -> :ok end) do
        DomainModelHandler.handle(:action, %{model_name: "LinearChannel", attrs: test_attrs})
        assert_called(LinearChannelHandler.handle(:action, test_attrs))
      end
    end

    test "Raise RuntimeError if model name is UnknownModel", %{test_attrs: test_attrs} do
      assert_raise RuntimeError, fn ->
        DomainModelHandler.handle(:action, %{model_name: "UnknownModel", attrs: test_attrs})
      end
    end
  end
end
