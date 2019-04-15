defmodule CtiKaltura.NodesService do
  @moduledoc """
  Возвращает список запущенных ядер.
  """

  def get_nodes do
    with topologies when not is_nil(topologies) <-
           Application.get_env(:libcluster, :topologies, nil),
         nodes_list <- topologies[:cti_kaltura][:config][:hosts],
         true <- Node.self() in nodes_list do
      nodes_list
    else
      _ ->
        [Node.self()]
    end
  end
end
