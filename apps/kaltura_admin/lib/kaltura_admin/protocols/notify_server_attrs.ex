## Protocol for serializing record data to map.
## Because any data those transfering between different paths of application must be primitive type.
defprotocol KalturaAdmin.Protocols.NotifyServerAttrs do
  @doc ""
  @spec get(data :: map()) :: map()
  def get(record)
end
